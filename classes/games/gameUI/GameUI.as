package games.gameUI 
{
	import events.RequestEvent;
	import flash.display.MovieClip;
	import flash.utils.Timer;
	import playerio.Connection;
	import playerio.Message;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class GameUI extends MovieClipContainer
	{
		private var _chat:Chat;
		private var _powerups:Array = [];
		private var _myTurn:Boolean = false;
		private var _playerItems:Array = [];			
		private var _players:Array = []; //objects per player (id, color, picture...)
		private var _connection:Connection;
		private var _gameName:String;
		
		public function GameUI(gameName:String, players:Array, connection:Connection) 
		{
			super (new MovieClip(), 0.6, 0.6);
			_gameName = gameName;
			_connection = connection;
			_players = players;
			_myTurn = gameName != Misc.STACK_UP_GAME;
			
			trace("GameUI constructor");
			t.obj(players);
			
			if (gameName != Misc.SNAKE_GAME) //no chat at snake. Because snake is recorded game, no realtime there
			{
				_chat = new Chat(_players, _connection);
				addChild(_chat);
			}						
			
			var powerupsForGame:Array = PowerupsManager.getPowerupsForGame(gameName);
			for (var i:int = 0; i < powerupsForGame.length; i++)
			{
				var powerup:Powerup = new Powerup(powerupsForGame[i], i);				
				_powerups.push(powerup);
				powerup.addEventListener(RequestEvent.TRY_USE_ME, tryShowUseMe);				
				addChild(powerup);
				
				for (var j:int = 0; j < PowerupsManager.powerups.length; j++ ) //write down amounts
				{
					if (PowerupsManager.powerups[j].type == powerupsForGame[i]) //if we have current (i) powerup, show how many and "activate" powerup item
					{						
						powerup.amount = PowerupsManager.powerups[j].amount;
					}
				}
			}
			
			for (var m:int = 0; m < _players.length; m++)
			{				
				var playerItem:PlayerItem = new PlayerItem(Networking.client.connectUserId == _players[m].id);
				_playerItems.push(playerItem);			
				
				playerItem.createGuy(_players[m].id, Misc.POSSIBLE_COLORS[_players[m].color], Networking.client.connectUserId == _players[m].id?UserData.photoURL:_players[m].photoURL); //user photo is taken from UserData.photo by BasicPlayerItem
				playerItem.createLevelPicture(_players[m].level);
				addChild(playerItem);
			}
			
			var settingsManager:SettingsManager = new SettingsManager(_gameName);
			addChild(settingsManager);
		}
		
		public function addChatMessage(message:Message):void 
		{
			_chat.addMessage(message.getString(0), message.getString(1)); 
		}
		
		private function tryShowUseMe(e:RequestEvent):void 
		{
            var powerup:Powerup = Powerup(e.currentTarget);
			if (_myTurn && powerup.usePossible && UserData.openedSnake)
			{
                powerup.showUseMe();
			}
		}
		
		public function get players():Array { return _players;	}			
		public function get myTurn():Boolean {	return _myTurn;	}
		public function set myTurn(value:Boolean):void 	{ _myTurn = value; }			
		public function get powerups():Array {	return _powerups;	}
	}
}