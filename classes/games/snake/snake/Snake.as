package games.snake.snake 
{
    import events.RequestEvent;

    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    import flash.utils.getDefinitionByName;

    import games.snake.SnakeData;
    import games.snake.field.Mine;
    import games.snake.field.SnakeField;

    /**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public class Snake extends MovieClip
	{
		protected var _direction:String;
		protected var _parts:Vector.<SnakePart> = new Vector.<SnakePart>();
		protected var _color:int;		
		protected var _turnPushPossible:Boolean = true; //to make impossible turning in several directions at a time. (pushing several turns with the same coordinate)
		protected var _growCount:int;
		protected var _tokens:int = 999999999; //1 token per 3px movement; 3px * 8tokens = 24px movement. 4 cells in a second. If tokens used-out - then no movements possible
		protected var _mines:Vector.<Mine> = new Vector.<Mine>();
		protected var _minePlaceRequest:Object;
		protected var _placeMineCounter:int;
		protected var _boostState:String = "";
		private var _boostTokens:int;
		private var _boostRequest:Object = null;
		private var _crazyStateTimer:Timer = new Timer(5000, 1);
		private var _turnsToProcess:Array = [];
		private var _dispatchExactlyCell:Boolean = false; //if true will dispatch event on each exactlyCell		
		
		public function Snake(situationID:int, color:int, oppTurnData:Array = null)  //create default snake, place it at coordinates
		{		
			if (oppTurnData != null) 
			{
				t.obj(oppTurnData);
				_turnsToProcess = nameDirections(oppTurnData); //save turns for opponent
			}
			_color = color;
			_direction = SnakeData.DIRECTIONS_NAMES[SnakeData.DIRECTIONS[situationID]];
			
			_parts.push(new SnakePart("tail", _direction, color));
			_parts.push(new SnakePart("body", _direction, color));
			_parts.push(new SnakePart("head", _direction, color));
			
			var startI:int = SnakeData.POSITIONS_I[situationID];
			var startJ:int = SnakeData.POSITIONS_J[situationID];
			
			for (var i:int = 0; i < _parts.length; i++ ) 
			{					
				_parts[i].direction = _direction;
				var adjuster:int = i - (_parts.length - 1);
				if (_direction == "right") _parts[i].setStartPoint(startI + adjuster, startJ);	
				else if (_direction == "down") _parts[i].setStartPoint(startI, startJ + adjuster);	
				else if (_direction == "left") _parts[i].setStartPoint(startI - adjuster, startJ);	
				else if (_direction == "up") _parts[i].setStartPoint(startI, startJ - adjuster);	
				addChild(_parts[i]);
			}			
		}		
		
		private static function nameDirections(oppTurnData:Array):Array
		{
			for (var i:int = 0; i < oppTurnData.length; i++) 
			{
				oppTurnData[i].direction = SnakeData.getDirectionName(oppTurnData[i].direction);
			}
			return oppTurnData;
		}
		
		public function move():void
		{ 				
			if (!_crazyStateTimer.running)
			{				
				if (_growCount > 0 && _parts[0].growModeCounter == 0 && _parts[1].growModeCounter == 0) grow(); //if there are items in da "belly" & previous item was fully consumed	
				
				var previousHeadI:int = head.realI; //for boost check
				var previousHeadJ:int = head.realJ; //for boost check
				
				for each (var part:SnakePart in _parts)
                {
                    part.move();
                }
				
				if (SnakeData.isExactly(head))
				{
					for each (var snakePart:SnakePart in _parts)
                    {
                        snakePart.changeRealCoordinates();
                    }
					var startedSevenMinesPlacement:Boolean = tryPlaceMine(previousHeadI, previousHeadJ);					
					if (dispatchExactlyCell) dispatchEvent(new RequestEvent(RequestEvent.EXACTLY_CELL, {previousHeadI:previousHeadI, previousHeadJ:previousHeadJ}));					
					checkForTurn(startedSevenMinesPlacement);
					for each (var snPart:SnakePart in _parts) //saying "hey, bitch, turn!" from here, ordering turns if exactly cell. == -1 / == 23 - either turn finisher or we gonna do double turn
					{
						if (snPart.growModeCounter == 0 && (snPart.turnCounter == -1 || snPart.turnCounter == (SnakeData.PART_SIZE / head.STEP_SIZE - 1)))
                        {
                            snPart.tryTurn();
                        }
					}					
					hitTestHead();
					checkForBoost(previousHeadI, previousHeadJ);					
					if (_boostTokens > 0) _boostTokens--;
				}
				_tokens--;	
			}		
		}	
		
		private function checkForBoost(previousHeadI:int, previousHeadJ:int):void 
		{
			if (_boostRequest)
			{
				//t.obj(_boostRequest);
				//trace("head.i: " + head.i + " head.j: " + head.j);
				if (SnakeData.checkPowerupTargetCell(previousHeadI, previousHeadJ, head.i, head.j, _boostRequest))
				{
					dispatchEvent(new RequestEvent(RequestEvent.BOOST_ME, { triple:_boostRequest.triple } ));					
					_boostRequest = null;
				}
			}
		}
		
		protected function tryPlaceMine(previousHeadI:int, previousHeadlJ:int):Boolean //overriden at SnakeForUser (no need to check for coordinates match to start placing)
		{			
			var startedSevenMinesPlacement:Boolean = false;
			
			if (_minePlaceRequest != null) //check for mine placing request
			{
				if (SnakeData.checkPowerupTargetCell(previousHeadI, previousHeadlJ, head.realI, head.realJ, _minePlaceRequest)) //if snake is at point were snake-mine-placer incremented placeMIneCounter
				{
					trace("started mine when head at: " + head.realI + " : " + head.realJ);
					_placeMineCounter += SnakeField.MINES_IN_SET;
					_minePlaceRequest = null;
				}
			}
			
			if (_placeMineCounter > 0)
			{
				var mineHereExists:Boolean = false; //so mine on top of the mine won't be placed
				for each (var mine:Mine in _mines) if (mine.i == _parts[0].realI && mine.j == _parts[0].realJ) mineHereExists = true;
				
				var atFieldBorder:Boolean = false;
				if (_parts[0].realI == -1 || _parts[0].realI == SnakeData.FIELD_WIDTH || _parts[0].realJ == SnakeData.FIELD_HEIGHT || _parts[0].realJ == -1) atFieldBorder = true;
				
				if (!mineHereExists && !atFieldBorder)
				{					
					trace("placed mine at: " + _parts[0].realI + " : " + _parts[0].realJ);					
					dispatchEvent(new RequestEvent(RequestEvent.PLACE_MINE, { color:_color, i:_parts[0].realI, j:_parts[0].realJ } ));	
					placeMineCounter--;
					if (placeMineCounter == (SnakeField.MINES_IN_SET - 1)) startedSevenMinesPlacement = true;
				}				
			}			
			return startedSevenMinesPlacement;
		}
		
		protected function checkForTurn(startedSevenMinesPlacement:Boolean = false):void 
		{
			if (_turnsToProcess.length > 0 && _turnsToProcess[0].i == head.i && _turnsToProcess[0].j == head.j)
			{
				var newTurn:Object = _turnsToProcess[0];
				var doubleTurn:Boolean = (_parts[_parts.length - 2].turnCounter >= (SnakeData.PART_SIZE / head.STEP_SIZE) - 1);				
				var oneCellBack:Object = SnakeData.backwardCell(newTurn.i, newTurn.j, _direction);
				var marginal:Boolean = (_direction == "left" && head.i >= (SnakeData.FIELD_WIDTH - 1)) || (_direction == "right" && head.i <= 0) || (_direction == "up" && head.j >= (SnakeData.FIELD_HEIGHT - 1)) || (_direction == "down" && head.j <= 0);	   	  	
				for each (var part:SnakePart in _parts) 
				{
					if (part.type != "head") part.addTurn(oneCellBack.i, oneCellBack.j, newTurn.direction, doubleTurn, marginal?_direction:"");
					else part.addTurn(head.i, head.j, newTurn.direction, false, marginal?_direction:"");
					part.trytryTurn(marginal, _parts.indexOf(part) == _parts.length - 2);					
					part.realFutureTurns.push( { i:head.realI, j:head.realJ, direction:newTurn.direction } );
					part.tryRealTurn();
				}
				
				_direction = newTurn.direction;
				_turnsToProcess.shift();				
			}
		}		
		
		private function hitTestHead():void 
		{
			for (var i:int = 0; i < _parts.length - 3; i++ ) //test for eating itself
			{
				if (head.realI == parts[i].realI && head.realJ == parts[i].realJ) 
				{	
					trace("Head hit bumped into: " + _parts[i].i + " - " + _parts[i].j + " part index:  " + i + " turnCounter: " + _parts[i + 1].turnCounter + "  parts eaten: " + (i + 1));
					var powerupStateFrame:int = _parts[0].itemGraphics.mc.powerups_mc.currentFrame;
					
					_parts[i + 1].turnToTail(); //show tail at new place
					for (var j:int = i; j >= 0; j--) //go through all the parts "chopped off" and delete them
					{				
						trace("removed part: " + j);
						createCloud(_parts[j]);
						removeChild(_parts[j]);
						_parts.splice(j, 1);						
					}
					dispatchEvent(new RequestEvent(RequestEvent.SHOW_POINT_CHANGE, { name:this.name, value: -(i + 1) }, true ));	
					
					if (powerupStateFrame > 1) //if eaten itself during boost state -> make new tail with turbines also
					{
						_parts[0].itemGraphics.mc.powerups_mc.gotoAndStop(powerupStateFrame);
						_parts[0].itemGraphics.mc.powerups_mc.powerup_mc.play();
					}
					
					if (SoundManager.soundsOn)
                    {
                        SoundManager.sounds["eatenitself"].play();
                    }
				}
			}
			
			for (i = 0; i < _mines.length; i++ ) //test for hitting a mine
			{
				if (_mines[i].i == head.realI && _mines[i].j == head.realJ && _mines[i].creator != this.name) 
				{
					if (SoundManager.soundsOn)
                    {
                        SoundManager.sounds["explosion"].play();
                    }
					dispatchEvent(new RequestEvent(RequestEvent.REMOVE_MINE, { mine:_mines[i] } ));
					_mines.splice(i, 1);
					goCrazy();
				}
			}
		}
		
		public function planBoost(preTargetCellI:int, preTargetCellJ:int, targetCellI:int, targetCellJ:int, triple:Boolean = false):void
		{
			_boostRequest = { preTargetCellI:preTargetCellI, preTargetCellJ:preTargetCellJ, targetCellI:targetCellI, targetCellJ:targetCellJ, triple:triple };			
		}
		
		public function goCrazy():void
		{
			head.itemGraphics.mc.mc_mc.gotoAndPlay("crazy");					
			_crazyStateTimer.addEventListener(TimerEvent.TIMER_COMPLETE, finishCrazyState);
			_crazyStateTimer.start();
		}
		
		private function finishCrazyState(e:TimerEvent):void 
		{
			head.itemGraphics.mc.mc_mc.gotoAndStop(1);	
		}
		
		private function createCloud(part:SnakePart):void 
		{
			var clou:Class = getDefinitionByName("cloud") as Class;
			var cloud:MovieClip = new clou() as MovieClip;	
			cloud.x = part.realI * SnakeData.PART_SIZE + SnakeData.PART_SIZE / 2;
			cloud.y = part.realJ * SnakeData.PART_SIZE + SnakeData.PART_SIZE / 2;
			cloud.addEventListener(Event.ENTER_FRAME, cloudEnterFrame);					
			addChild(cloud);
		}
		
		private function cloudEnterFrame(e:Event):void 
		{
			if ((e.currentTarget as MovieClip).currentFrame == (e.currentTarget as MovieClip).totalFrames)
			{
				e.currentTarget.removeEventListener(Event.ENTER_FRAME, cloudEnterFrame);
				removeChild(e.currentTarget as MovieClip);
			}
		}
		
		private function grow():void //previous part 1 becomes part 2, part 2 - part 3, 3 - 4, etc... 
		{
			var newSnakePart:SnakePart = new SnakePart(_parts[1].type, _parts[1].direction, _parts[1].color);//first body part
			newSnakePart.i = _parts[1].i;
			newSnakePart.j = _parts[1].j;
			newSnakePart.x = _parts[1].x;
			newSnakePart.y = _parts[1].y;
			newSnakePart.realI = _parts[1].realI;
			newSnakePart.realJ = _parts[1].realJ;
			newSnakePart.realDirection = _parts[1].realDirection;
			newSnakePart.doubleTurn = _parts[1].doubleTurn;
			for each (var turn:Object in _parts[1].futureTurns)
            {
                newSnakePart.futureTurns.push(turn); //can't just make a link 2 it. Need 2 make a copy
            }
			for each (var turnObj:Object in _parts[1].realFutureTurns)
            {
                newSnakePart.realFutureTurns.push(turnObj); //can't just make a link 2 it. Need 2 make a copy
            }
			newSnakePart.itemGraphics.currentFrame = _parts[1].itemGraphics.currentFrame;
			newSnakePart.itemGraphics.scaleX = _parts[1].itemGraphics.scaleX;
			newSnakePart.reverseMe = _parts[1].reverseMe;
			newSnakePart.turnCounter = _parts[1].turnCounter;
			newSnakePart.turnDirection = _parts[1].turnDirection;
			if (_parts[1].withHead && _parts[1].itemGraphics.currentFrame > 25) newSnakePart.itemGraphics.currentFrame -= 25;
			newSnakePart.setGrowModeCounter();
			_parts[0].setGrowModeCounter();//freeze tail also
			_parts.splice(1, 0, newSnakePart);
			addChildAt(newSnakePart, getChildIndex(_parts[0]));
			_growCount--;
		}			
		
		protected function checkForMinePlaceRequest():void { } //used at SnakeForUser
		
		public function get parts():Vector.<SnakePart> { return _parts; }
		public function get head():SnakePart {return _parts[_parts.length - 1];}			
		public function get growCount():int { return _growCount; }
		public function set growCount(value:int):void {	_growCount = value;	}		
		public function get tokens():int { return _tokens; }
		public function set tokens(value:int):void {_tokens = value;}
		public function get placeMineCounter():int 	{return _placeMineCounter;}		
		public function set placeMineCounter(value:int):void {_placeMineCounter = value;}		
		public function get minePlaceRequest():Object {	return _minePlaceRequest;}		
		public function set minePlaceRequest(value:Object):void {	_minePlaceRequest = value; }
		public function get mines():Vector.<Mine> {	return _mines;}
		public function set mines(value:Vector.<Mine>):void { _mines = value; }
		public function get dispatchExactlyCell():Boolean {return _dispatchExactlyCell;}		
		public function set dispatchExactlyCell(value:Boolean):void {_dispatchExactlyCell = value; }
		public function get color():int { return _color; } //used when colorising missile
		public function get boostState():String { return _boostState; }
		public function set boostState(value:String):void {	_boostState = value;}				
		public function get turnsToProcess():Array 	{ return _turnsToProcess; }
		public function set turnsToProcess(value:Array):void { _turnsToProcess = value;}
		public function get boostTokens():int {	return _boostTokens;}		
		public function set boostTokens(value:int):void {_boostTokens = value; }
	}
}