package games.stackUp 
{
    import com.actionsnippet.qbox.QuickBox2D;

    import events.RequestEvent;

    import Box2D.Common.Math.b2Vec2;

    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.utils.Timer;

    import games.Game;
    import games.gameUI.PlayerItem;
    import games.gameUI.Powerup;

    import playerio.Connection;
    import playerio.Message;

    import popups.tutorial.StackUpTutorial;

    /**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class StackUpGame extends Game
	{
		private var _placedShapes:Array = [];
		private var _placedShapesObjects:Array = [];
		private var _shapesBox:ShapesBox;
		private var _world:World;	
		private var _sim:QuickBox2D;		
		private var _previousFrameStates:Array = []; //contains y-properties of all placed shapes (after placing another one) -> used 2 check y-change & detect falling of pedestal
		private var _myID:String;
		private var _messageManager:MessageManager;
		private var _turnTimer:Timer = new Timer(970, 20); //15 secs per turn. -35 secs - so user has some extra time.  + //used 4 displaying time left 2 stabilize. It's not connected 2 any sending. There is a timer at server for it.
		private var _dropSyncWriteTimer:Timer = new Timer(40, 4);
		private var _dropSyncApplyTimer:Timer = new Timer(40, 4);
		private var _faceManager:FaceManager; //plays faces animation from time to time
		private var _droppedShapeData:Array = []; //x,y,rot - x,y,rot - x,y,rot
		private var _stabilizeCounter:int; //when it's "OK" 10 times in a row - then send "ok" 
		private var _tutorial:StackUpTutorial; //used at tutorial
		private var _mouseMoveCounterSkipper:int = 0;
		
		public function StackUpGame(connection:Connection, gameName:String) 
		{
			_myID = Networking.client.connectUserId;
			
			super(connection, gameName);		
			
			_connection.addMessageHandler("0", moveOtherShape); //move shape
			_connection.addMessageHandler("ds", dropOtherShape); //drop shape
			_connection.addMessageHandler("er", disconnectError); // when after shape drop instead of "ok-ok" or "0-0" somewhat like "ok-0" is received. (cheating or async)
			_connection.addMessageHandler("nt", nextTurn); //next turn
			_connection.addMessageHandler("sw", function(message:Message):void { createShape(message.getInt(0)); } ); //swap shape powerup
			_connection.addMessageHandler("ns", function(message:Message):void { createShape(777); } ); //place nano shape
			_connection.addMessageHandler("un", undo); //remove last shape (undo)
			_connection.addMessageHandler("fb", function(message:Message):void { createShape(888); } ); //flying bar
			
			_dropSyncWriteTimer.addEventListener(TimerEvent.TIMER, writeDroppedShapeData);
			_dropSyncWriteTimer.addEventListener(TimerEvent.TIMER_COMPLETE, sendDroppedShapeData);
			_dropSyncApplyTimer.addEventListener(TimerEvent.TIMER, applyDroppedShapeData);
			_dropSyncApplyTimer.addEventListener(TimerEvent.TIMER_COMPLETE, clearData);
		}
		
		override protected function startGame(message:Message):void
		{	
			Networking.socialNetworker.publishPlayedGameAction(Misc.STACK_UP_GAME);
			
			try
			{			
				_world = new World(message.getInt(2));
				addChild(_world);
			}
			catch (er:Error)
			{
				Networking.client.errorLog.writeError("Error at creating world (loading new RSL): ", message.getInt(2) + ". " + er.message + " . " + er.name, er.getStackTrace(), null);				
			}
			
			try
			{
				createSim();
			}
			catch (e:Error) //sometimes: Cannot access a property or method of a null object reference.	at com.actionsnippet.qbox::QuickBox2D/init(). No idea why.
			{
				Networking.client.errorLog.writeError("error at _sim creation: ", e.errorID.toString() + ": " + e.message, e.getStackTrace(), null);
				if (_world == null) Networking.client.errorLog.writeError("world was null at sim creation: ", "", "", null);
				if (_world != null && contains(_world)) removeChild(_world);
				_sim = null;
				Misc.delayCallback(function():void { startGame(message);} , 50); //with timer so no stackOverFlow will happen
			}
			
			try
			{	
				if (message.getInt(2) == 0) _sim.gravity = new b2Vec2(0, 10); //at sea "gravity" is lower. micro-feature
				ShapeCreator.addBoundaries(_world, _sim, message.getInt(2));
			} 
			catch (er:Error) 
			{ 
				Networking.client.errorLog.writeError("error at ShapeCreator.addBoundaries: ", er.errorID + ": " + er.message, er.getStackTrace(), null);
				if (_world != null && contains(_world)) removeChild(_world);
				if (_sim != null) 
				{
					_sim.stop();
					_sim = null;
				}
				Misc.delayCallback(function():void { startGame(message); }, 100); //with timer so no stackOverFlow will happen
			}	
			
			_shapesBox = new ShapesBox();
			_shapesBox.addEventListener(MouseEvent.MOUSE_DOWN, startShapeDrag);
			addChild(_shapesBox);
			
			_messageManager = new MessageManager(_users);			
			addChild(_messageManager);
			
			_whoseTurn = message.getString(1);
			showWhoseTurn(true);
			
			createShape(message.getInt(0));			
			
			_turnTimer.addEventListener(TimerEvent.TIMER, showTurnTimeLeft);			
			_turnTimer.start();
			
			_lastScreenshot = Misc.snapshot(_world.mc, Misc.GAME_AREA_WIDTH, Misc.GAME_AREA_HEIGHT); //so there won't be a white (empty) screen if guys fail at 1st turn
			
			if (message.getInt(2) == 2) _timerPanel.goWhite();
			
			_faceManager = new FaceManager(_placedShapes);					
		}
		
		private function createSim():void 
		{			
			_sim = new QuickBox2D(_world.mc, { iterations:50 } ); //debug:true, iterations:50 - default is 20. More precise calculations
			_sim.setDefault( { draggable:false } ); //every shape in simulation will not be draggable and will be bullet (precise hittesting)  , isBullet:true
			_sim.start();
			_sim.mouseDrag();
			
		}
		
		private function clearData(e:TimerEvent = null):void {_droppedShapeData = [];}
		
		private function applyDroppedShapeData(e:TimerEvent):void 
		{
			_placedShapes[_placedShapes.length - 1].x = _droppedShapeData[(_dropSyncApplyTimer.currentCount - 1) * 3];
			_placedShapes[_placedShapes.length - 1].y = _droppedShapeData[(_dropSyncApplyTimer.currentCount - 1) * 3 + 1];
			_placedShapes[_placedShapes.length - 1].rotation = _droppedShapeData[(_dropSyncApplyTimer.currentCount - 1) * 3 + 2];
		}
		
		private function writeDroppedShapeData(e:TimerEvent):void 
		{
			_droppedShapeData.push(_placedShapes[_placedShapes.length - 1].x, _placedShapes[_placedShapes.length - 1].y, _placedShapes[_placedShapes.length - 1].rotation);
		}
		
		private function sendDroppedShapeData(e:TimerEvent):void 
		{
			_connection.send("ds", _droppedShapeData.join(","));
		}
		
		private function showTurnTimeLeft(e:TimerEvent):void 
		{
			_timerPanel.mc.timer_txt.text = (_turnTimer.repeatCount - _turnTimer.currentCount).toString();			
			if (_nonStableCounter > 80) _messageManager.tryShowReeling();
		}
		
		private function checkShapes(e:Event):void 
		{
			var noChange:Boolean = true;
			for (var i:int = 0; i < _placedShapes.length; i++) //for each droppped shape
			{
				if (_previousFrameStates[i].x != _placedShapes[i].x || _previousFrameStates[i].y != _placedShapes[i].y || Math.abs(_previousFrameStates[i].rotation - _placedShapes[i].rotation) > 0.3) //i % 2 == 0 if it's y-coordinate. Else - x) 
				{		
					if (_placedShapes[i].hitTestObject(_world.mc.hitTest_mc)) //check for falling down (590 - pedestal y)
					{			
						_connection.send("fe");
						Networking.client.stage.removeEventListener(Event.ENTER_FRAME, checkShapes);						
					}
					else //no fall, but some coordinates changed
					{							
						_previousFrameStates[i].x = _placedShapes[i].x;
						_previousFrameStates[i].y = _placedShapes[i].y;	
						_previousFrameStates[i].rotation = _placedShapes[i].rotation;
					}				
					noChange = false; //means y-property of certain shape changed from last frame	
					_nonStableCounter++;
				}			
			}
			_stabilizeCounter = noChange?_stabilizeCounter + 1:0; //increment if ok. Make 0 again if fail
			if (_stabilizeCounter == 10) 
			{
				_connection.send("ok");
				Networking.client.stage.removeEventListener(Event.ENTER_FRAME, checkShapes);
				_stabilizeCounter = 0;
			}
		}
		
		private function startShapeDrag(e:MouseEvent):void 
		{
			if (_whoseTurn == _myID && _shapesBox.currentShape != null) //sometimes u can MOUSE_DOWN right after dropping a shape
			{
				_shapesBox.currentShape.alpha = 100;
				_shapesBox.currentShape.x = mouseX;
				stage.addEventListener(MouseEvent.MOUSE_UP, dropShape);				
				stage.addEventListener(Event.ENTER_FRAME, moveShape);	
			}					
		}
		
		private function moveShape(e:Event):void 
		{
			_mouseMoveCounterSkipper++;
			if (_mouseMoveCounterSkipper % 5 == 0) //sending only each 5th move
			{
				_connection.send("0", int(mouseX), int(mouseY));				
			}						
			_shapesBox.currentShape.x = mouseX;
			_shapesBox.currentShape.y = mouseY;	
		}
		
		private function moveOtherShape(message:Message):void 
		{			
			_shapesBox.currentShape.x = message.getInt(0);
			_shapesBox.currentShape.y = message.getInt(1);
		}		
		
		private function dropShape(e:MouseEvent):void 
		{					
			_placedShapesObjects.push(ShapeCreator.addShape(_shapesBox.currentShape, _sim, _world));
			
			_placedShapes.push(_shapesBox.currentShape);					
			_previousFrameStates = [];
			for each (var shape:MovieClip in _placedShapes)
            {
                _previousFrameStates.push({x:shape.x, y:shape.y, rotation:shape.rotation});
            }
			_shapesBox.removeShape();		
			
			Networking.client.stage.removeEventListener(MouseEvent.MOUSE_UP, dropShape);
			Networking.client.stage.removeEventListener(Event.ENTER_FRAME, moveShape);
			Networking.client.stage.addEventListener(Event.ENTER_FRAME, checkShapes);	
			
			_droppedShapeData = [];
			_dropSyncWriteTimer.reset();
			_dropSyncWriteTimer.start(); //it'll send data in 120 ms	
			
			_gameUI.myTurn = false;
		}	
		
		private function dropOtherShape(message:Message):void 
		{					
			_placedShapesObjects.push(ShapeCreator.addShape(_shapesBox.currentShape, _sim, _world));
			_placedShapes.push(_shapesBox.currentShape); 
			
			_previousFrameStates = [];
			for each (var shape:MovieClip in _placedShapes)
            {
                _previousFrameStates.push({x:shape.x, y:shape.y, rotation:shape.rotation});
            }
			_shapesBox.removeShape();		
			
			Networking.client.stage.addEventListener(Event.ENTER_FRAME, checkShapes);
			
			_droppedShapeData = message.getString(0).split(",");
			_dropSyncApplyTimer.reset();
			_dropSyncApplyTimer.start();	
		}
		
		private function nextTurn(message:Message):void 
		{				
			_timerPanel.mc.timer_txt.text = "15";
			_nonStableCounter = 0;
			if (_world.mc.getChildByName("front2") != null)
            {
                _world.mc.setChildIndex(_world.mc.getChildByName("front2"), _world.mc.numChildren - 1); //set front shell at the top
            }
			_lastScreenshot = Misc.snapshot(_world.mc, Misc.GAME_AREA_WIDTH, Misc.GAME_AREA_HEIGHT);
			(_gameUI.getChildByName(_whoseTurn) as PlayerItem).changePoints(1); //add points to previous turn guy
			_whoseTurn = message.getString(0);
			createShape(message.getInt(1));
			showWhoseTurn();
			_turnTimer.reset();
			_turnTimer.start();
		}
		
		private function showWhoseTurn(firstTime:Boolean = false):void
		{			
			_gameUI.myTurn = _whoseTurn == _myID;
			if (_gameUI.myTurn && SoundManager.soundsOn)
                SoundManager.sounds["yourturn"].play();
			
			for each (var pu:Powerup in _gameUI.powerups)
			{
				if (_whoseTurn == _myID && pu.usePossible)
                    pu.turnOn(); //undo is turned off 1st time
				else
                    pu.turnOff();
				
				if (_placedShapes.length == 0 && pu.name == "undo")
                    pu.turnOff(); //turn off "undo" first time
				else if (_placedShapes.length == 1 && pu.name == "undo")
                    pu.lifeTime = PowerupsManager.getPowerupLifetime(pu.name); //turn on undo
			}
			
			_shapesBox.mc.mc.drag_txt.visible = _whoseTurn == _myID;
			
			tryCreateTutorial();
			tryShowTips(firstTime);				
			
			_messageManager.showNextTurn(_whoseTurn);					
		}
		
		private function tryCreateTutorial():void 
		{
			if (!UserData.openedStackUp && _gameUI.myTurn && _tutorial == null)
			{
				Misc.delayCallback(function():void
				{
					Networking.socialNetworker.publishFirstGame(Misc.STACK_UP_GAME, getOppName()); //FB pubishes "I started playing Snake Battle game at Winner's Way."
					_tutorial = new StackUpTutorial();
					Networking.client.stage.addEventListener(MouseEvent.MOUSE_UP, hideTutorial);
					addChildAt(_tutorial, getChildIndex(_shapesBox));
				}, 50);			
			}			
		}
		
		private function tryShowTips(firstTime:Boolean):void 
		{
			if (_whoseTurn != _myID && !firstTime && !UserData.openedStackUp) //tips were not created yet
			{
				if (_tutorial.state == "tutorialShown")
                {
                    _tutorial.showFirstTips();
                }
				else if (_tutorial.state == "firstTipsShown")
                {
                    _tutorial.showSecondTips(); //and the following last 2
                }
			}
		}
		
		private function hideTutorial(e:MouseEvent):void 
		{
			Networking.client.stage.removeEventListener(MouseEvent.MOUSE_UP, hideTutorial);
			_tutorial.hide();
		}
		
		override protected function usePowerup(e:RequestEvent):void 
		{			
			if (e.stuff.name == "swapShape")
            {
                _connection.send("sw", uint(_shapesBox.currentShape.name));
            }
			else if (e.stuff.name == "nanoShape")
            {
                _connection.send("ns", uint(_shapesBox.currentShape.name));
            }
			else if (e.stuff.name == "undo")
            {
                _connection.send("un");
            } //if shapes are reeling more than 1 sec
			else if (e.stuff.name == "flyingbar")
            {
                _connection.send("fb");
            } //flying bar
		}
		
		private function undo(message:Message):void
		{
			_placedShapesObjects[_placedShapesObjects.length - 1].destroy();
			_placedShapesObjects.pop();
			_placedShapes.pop();
		}		
		
		override protected function finishGame(message:Message, jackpotWin:Boolean = false):void
		{
			Misc.delayCallback(function():void
			{
				createFinishGamePopup(message, jackpotWin);
				clearUp();
			}, 2500);			
		}
		
		private function disconnectError(message:Message):void 
		{
			trace(message);
			clearUp(false);
			_messageManager.showAsyncError();			
			var timer:Timer = new Timer (4000, 1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(e:TimerEvent):void {
                dispatchEvent(new RequestEvent(RequestEvent.REMOVE_ME)) } );
			timer.start();			
		}
		
		private function clearUp(removeMovieclips:Boolean = true):void
		{
			if (Networking.client.stage.hasEventListener(Event.ENTER_FRAME))
            {
                Networking.client.stage.removeEventListener(Event.ENTER_FRAME, checkShapes);
            }
			_turnTimer.stop();
			_faceManager.stopTimer();
			_messageManager.alphaOff();	
			_connection.removeMessageHandler("0", moveOtherShape); //move shape
			_connection.removeMessageHandler("ds", dropOtherShape); //drop shape
			_connection.removeMessageHandler("er", disconnectError); // when after shape drop instead of "ok-ok" or "0-0" somewhat like "ok-0" is received. (cheating or async)
			_connection.removeMessageHandler("nt", nextTurn); //next turn
			_connection.removeMessageHandler("sw", function():void {  } ); //swap shape powerup
			_connection.removeMessageHandler("ns", function():void {  } ); //place nano shape
			_connection.removeMessageHandler("un", undo); //remove last shape (undo)
			_connection.removeMessageHandler("fb", function():void {  } ); //flying bar
			
			if (removeMovieclips)
			{
				if (_world.parent != null) removeChild(_world); //lol. Happens sometimes.
				_sim.stop();
				for each (var item:MovieClip in _placedShapes)
                {
                    if(item.parent != null)
                    {
                        (item.parent).removeChild(item);
                    }
                }
			}			
		}
		
		private function createShape(shapeType:int):void
		{
			trace("type " + shapeType);
			_shapesBox.createShape(new (ShapeCreator.getSkinByType(shapeType)) as MovieClip, shapeType);
		}
	}
}