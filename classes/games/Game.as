package games 
{
    import events.RequestEvent;

    import flash.display.Bitmap;
    import flash.display.Sprite;
    import flash.events.KeyboardEvent;
    import flash.net.SharedObject;
    import flash.ui.Keyboard;

    import games.gameUI.GameUI;
    import games.gameUI.Powerup;

    import net.hires.debug.Stats;

    import playerio.Connection;
    import playerio.Message;

    import popups.JPWin;
    import popups.finishPopup.FinishPopup;

    /**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public class Game extends Sprite
	{		
		protected var _connection:Connection; //need this field here because it may be user's room connection or other dude's connection (when joining other's room)
		protected var _gameLength:int = 0; //overriden in gameClasses. If not - no game timer
		protected var _timerPanel:TimerPanel;		
		protected var _gameUI:GameUI;
		protected var _users:Array = []; 
		protected var _whoseTurn:String; //used in StackUp
		protected var _nonStableCounter:int; //TODO: use powerups props instead
		protected var _lastScreenshot:Bitmap; 
		protected var _gameDataReady:Boolean = true; //at snake it's set to false. And back to true only when turnData is loaded
		private var _namesReady:Boolean = false;
		private var _gameName:String;
		
		public function Game(connection:Connection, gameName:String) 
		{		
			_gameName = gameName;			
			_connection = connection;
			_connection.addMessageHandler("st", removeButtons); //startGame message
			_connection.addMessageHandler("data", receiveGameData);			
			_connection.addMessageHandler("fo", dispatchShowFindingOpponent);
			_connection.addMessageHandler("finishjp", goFinishWithJackpot);
			_connection.addMessageHandler("finish", goFinish);
			_connection.addMessageHandler("ch", addChatMessage);
			//_connection.addMessageHandler("*", function(message:Message){trace(message)});			
			
			if (SharedObject.getLocal(Misc.SHARED_OBJECT_NAME).data.sounds)
                SoundManager.loadSoundsForGame(gameName); //load sounds if they are turned on
			if (SharedObject.getLocal(Misc.SHARED_OBJECT_NAME).data.music)
                SoundManager.loadMusicForGame(gameName); //load sounds if they are turned on
		}					
		
		private function dispatchShowFindingOpponent(mes:Message):void
		{
			dispatchEvent(new RequestEvent(RequestEvent.SHOW_FINDING_OPPONENT));
		}
		
		private function receiveGameData(message:Message):void 
		{		
			trace(message);
			
			var playersIDs:Array = message.getString(0).split(",");
			var colors:Array = message.getString(1).split(",");
			var levels:Array = message.getString(2).split(",");
			
			for (var i:int = 0; i < playersIDs.length; i++ ) 
			{
				var playerObj:Object = { id:playersIDs[i], color:int(colors[i]), level:int(levels[i]) };
				_users.push(playerObj);
				if (playersIDs[i] != Networking.client.connectUserId) //get name of the opponent
				{
					if (_gameName == Misc.SNAKE_GAME)
                        loadTurnsData(message.getInt(3));
					else if (_gameName == Misc.WORD_SEEKERS_GAME)
                        loadWordsData(message.getInt(3));
					Networking.socialNetworker.eventDispatcher.addEventListener(RequestEvent.IMREADY, onNamesLoaded);
					Networking.socialNetworker.getOpponentInfo(playerObj);
				}
			}			
		}
		
		private function onNamesLoaded(e:RequestEvent):void
		{
			trace("onNamesLoaded");
			t.obj(e.stuff);
			_namesReady = true;
			for (var i:int = 0; i < _users.length; i++) 
			{
				if (_users[i].id == e.stuff.id) _users[i] = e.stuff; //sometimes it was not saving PlayerObj from Socialetworker. 
			}
			Networking.socialNetworker.eventDispatcher.removeEventListener(RequestEvent.IMREADY, onNamesLoaded);
			trySendReady();
		}
		
		protected function trySendReady():void 
		{
			if (_namesReady && _gameDataReady) _connection.send("ready");
		}
		
		private function removeButtons(message:Message):void
		{		
			trace(message);	
			dispatchEvent(new RequestEvent(RequestEvent.LOADED_GAME_RSL));	
			
			_gameUI = new GameUI(_gameName, _users, _connection);
			_gameUI.addEventListener(RequestEvent.USE_POWERUP, tryPowerupUseClick);
			
			Networking.client.stage.addEventListener(KeyboardEvent.KEY_DOWN, tryPowerupUse);
			
			_timerPanel = new TimerPanel(_gameLength);
			if (_gameLength > 0)
            {
                _timerPanel.startTimerGame();
            }
			else if (_gameName == Misc.STACK_UP_GAME)
            {
                _timerPanel.startStackUp();
            }
			
			startGame(message);			
			
			addChild(_timerPanel);			
			addChild(_gameUI);		
			
			if (Networking.socialNetworker.ACRONYM == Networking.LOCAL) //only at test mode
			{
				var sts:Stats = new Stats();
				sts.y = 110;
				sts.x = 720;
				addChild(sts);
			}			
		}
		
		private function tryPowerupUseClick(e:RequestEvent):void  //by Mouse
		{
			if ((_gameUI.myTurn || (e.target.name == "freezeShapes" && _whoseTurn == Networking.client.connectUserId && _nonStableCounter > 80)) && (e.target as Powerup).usePossible)
			{
				if (!(_gameName == Misc.SNAKE_GAME && (e.target.name == "boost2x" || e.target.name == "boost3x") && (!(_gameUI.getChildByName("boost2x") as Powerup).useBoostPossible || !(_gameUI.getChildByName("boost3x") as Powerup).useBoostPossible))) //when no boost run now. IOW, anti-double-boost 
				{
					(e.target as Powerup).useMe();
					usePowerup(new RequestEvent(RequestEvent.USE_POWERUP, { name: e.target.name } ));
				}
			}
		}
		
		private function tryPowerupUse(e:KeyboardEvent):void //by Keyboard 
		{
			var powerupIndex:int = -1;			
				if (_gameUI.myTurn && (e.keyCode == Keyboard.NUMBER_1 || e.keyCode == Keyboard.NUMPAD_1) && _gameUI.powerups.length > 0 && _gameUI.powerups[0].usePossible) powerupIndex = 0;
			else if (_gameUI.myTurn && (e.keyCode == Keyboard.NUMBER_2 || e.keyCode == Keyboard.NUMPAD_2) && _gameUI.powerups.length > 1 && _gameUI.powerups[1].usePossible) powerupIndex = 1;
			else if (_gameUI.myTurn && (e.keyCode == Keyboard.NUMBER_3 || e.keyCode == Keyboard.NUMPAD_3) && _gameUI.powerups.length > 2 && _gameUI.powerups[2].usePossible) powerupIndex = 2; 
			else if (_gameUI.myTurn && (e.keyCode == Keyboard.NUMBER_4 || e.keyCode == Keyboard.NUMPAD_4) && _gameUI.powerups.length > 3 && _gameUI.powerups[3].usePossible) powerupIndex = 3;
			else if (_gameUI.myTurn && (e.keyCode == Keyboard.NUMBER_5 || e.keyCode == Keyboard.NUMPAD_5) && _gameUI.powerups.length > 4 && _gameUI.powerups[4].usePossible) powerupIndex = 4;
			else if (_gameUI.myTurn && (e.keyCode == Keyboard.NUMBER_6 || e.keyCode == Keyboard.NUMPAD_6) && _gameUI.powerups.length > 5 && _gameUI.powerups[5].usePossible) powerupIndex = 5;
			else if (_gameUI.myTurn && (e.keyCode == Keyboard.NUMBER_7 || e.keyCode == Keyboard.NUMPAD_7) && _gameUI.powerups.length > 6 && _gameUI.powerups[6].usePossible) powerupIndex = 6;
			else if (_gameUI.myTurn && (e.keyCode == Keyboard.NUMBER_8 || e.keyCode == Keyboard.NUMPAD_8) && _gameUI.powerups.length > 7 && _gameUI.powerups[7].usePossible) powerupIndex = 7;
			else if (_gameUI.myTurn && (e.keyCode == Keyboard.NUMBER_9 || e.keyCode == Keyboard.NUMPAD_9) && _gameUI.powerups.length > 8 && _gameUI.powerups[8].usePossible) powerupIndex = 8;
			
			if (powerupIndex > -1 && !(_gameName == Misc.SNAKE_GAME && ((e.keyCode == Keyboard.NUMBER_1 || e.keyCode == Keyboard.NUMPAD_1) || (e.keyCode == Keyboard.NUMBER_2 || e.keyCode == Keyboard.NUMPAD_2)) && (!(_gameUI.getChildByName("boost2x") as Powerup).useBoostPossible || !(_gameUI.getChildByName("boost3x") as Powerup).useBoostPossible))) //when no boost run now)) IOW, anti-double-boost 
			{
				usePowerup(new RequestEvent(RequestEvent.USE_POWERUP, { name: _gameUI.powerups[powerupIndex].name } ));
				_gameUI.powerups[powerupIndex].useMe();
			}
		}		
		
		private function addChatMessage(mes:Message):void 
		{
			_gameUI.addChatMessage(mes);
		}
		
		private function goFinishWithJackpot(mes:Message):void
		{
			finishGame(mes, true);
		}
		
		private function goFinish(mes:Message):void 
		{
			finishGame(mes, false);
		}
		
		protected function createFinishGamePopup(message:Message, jackpotWin:Boolean = false):void //stageScreenshot is made before clearing MCs. Thus popup is created when CPU-hard stuff is removed from stage
		{
			trace(message);		
			_connection.removeMessageHandler("fo", dispatchShowFindingOpponent);
			_connection.removeMessageHandler("st", removeButtons); 
			_connection.removeMessageHandler("data", receiveGameData);			
			_connection.removeMessageHandler("finishjp", goFinishWithJackpot);
			_connection.removeMessageHandler("finish", goFinish);
			_connection.removeMessageHandler("ch", addChatMessage);
			
			t.obj(_users);
			
			var popup:FinishPopup = new FinishPopup(message.getString(0), message.getString(1), _lastScreenshot, _users);
            if (!jackpotWin) popup.addEventListener(RequestEvent.REMOVE_ME, dispatchPopupRemove);
            else
            {
                var popupJP:JPWin = new JPWin(message.getInt(2)); //create right now, so it'll snapshot stage with game on bg
                popup.addEventListener(RequestEvent.REMOVE_ME, function(e:RequestEvent):void
                {
                    removeChild(popup);
                    popupJP.addEventListener(RequestEvent.REMOVE_ME, dispatchPopupRemove);
                    popupJP.visible = true;
                    popupJP.playScaleTween();
                });
                popupJP.visible = false;
                addChild(popupJP);
            }
			addChild(popup);
		}

		protected function getOppName():String
		{
			var oppName:String = "";
			for each (var item:Object in _users) 
			{
				if (item.id != UserData.id) oppName = item.name;
			}
			return oppName;
		}
		
		private function dispatchPopupRemove(e:RequestEvent):void
		{
			dispatchEvent(new RequestEvent(RequestEvent.REMOVE_ME, { showFullStory:e.stuff.showFullStory } ));
		}
		
		protected function startGame(message:Message):void { }		
		protected function finishGame(message:Message, jackpotWin:Boolean = false):void { }	 //each game finishes with it's own nuances
		protected function usePowerup(e:RequestEvent):void { }
		protected function loadTurnsData(gameID:int):void { }
		protected function loadWordsData(gameID:int):void { }
		public function get connection():Connection {	return _connection;	}
	}
}