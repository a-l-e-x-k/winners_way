package games.snake 
{
    import events.RequestEvent;

    import flash.display.Sprite;
    import flash.events.KeyboardEvent;
    import flash.ui.Keyboard;

    import games.Game;
    import games.gameUI.PlayerItem;
    import games.snake.field.SnakeField;
    import games.snake.field.TopField;

    import playerio.Connection;
    import playerio.DatabaseObject;
    import playerio.Message;

    import popups.tutorial.SnakeTurorial;

    /**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class SnakeGame extends Game 
	{
		protected const ROOM_CAPACITY:int = 2; 
		private var _snakeField:SnakeField;
		private var _topField:TopField;
		private var _oppTurnData:Array = [];
		
		public function SnakeGame(connection:Connection, gameName:String) 
		{
			super(connection, gameName);		
			_gameLength = 80 * 1000;
			_gameDataReady = false;
		}
		
		public function onKeyDown(e:KeyboardEvent):void 
		{
			if (e.keyCode == Keyboard.LEFT || e.keyCode == Keyboard.A)
            {
                _snakeField.turnMySnakeTo("left");
            }
			else if (e.keyCode == Keyboard.UP || e.keyCode == Keyboard.W)
            {
                _snakeField.turnMySnakeTo("up");
            }
			else if (e.keyCode == Keyboard.RIGHT || e.keyCode == Keyboard.D)
            {
                _snakeField.turnMySnakeTo("right");
            }
			else if (e.keyCode == Keyboard.DOWN || e.keyCode == Keyboard.S)
            {
                _snakeField.turnMySnakeTo("down");
            }
		}
		
		override protected function loadTurnsData(gameID:int):void
		{
			Networking.client.bigDB.load("SnakeGames", gameID.toString(), onGameDataLoaded, Misc.handleError);
		}
		
		private function onGameDataLoaded(gameObj:DatabaseObject):void 
		{
			_oppTurnData = gameObj.turnsArray;
			_gameDataReady = true;
			trySendReady();
		}
		
		override protected function startGame(message:Message):void
		{	
			_snakeField = new SnakeField(ROOM_CAPACITY, _users, Networking.client.connectUserId, message.getString(0).split(","), _connection, SnakeData.getFieldName(message.getInt(1)), _oppTurnData);
			_snakeField.addEventListener(RequestEvent.SHOW_POINT_CHANGE, function(e:RequestEvent):void
			{
				(_gameUI.getChildByName(e.stuff.name) as PlayerItem).changePoints(e.stuff.value);
			});
			addChild(_snakeField);
			
			_topField = new TopField(SnakeData.getFieldName(message.getInt(1)));
			addChild(_topField);
			addChild(_snakeField.grid);	
			
			Networking.client.stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);		
			
			if (!UserData.openedSnake) 
			{
				Misc.delayCallback(createTutorial, 250); //so it would be posisble to add tutorial on top of everything (gameUI is added to display list after call of createGame())				
			}
			else
            {
                Networking.socialNetworker.publishPlayedGameAction(Misc.SNAKE_GAME);
            }
		}
		
		private function createTutorial():void 
		{
			var snakeTutorial:SnakeTurorial = new SnakeTurorial();
			addChild(snakeTutorial);
			_gameUI.powerups[0].addEventListener(RequestEvent.WAS_USED, function(e:RequestEvent):void //shows 2nd powerup tutorial (3x boost)
			{ 
				snakeTutorial.prepareForSecondPowerupTutorial(); 				
			});	
			_gameUI.powerups[1].addEventListener(RequestEvent.WAS_USED, function(e:RequestEvent):void //shows 2nd powerup tutorial (3x boost)
			{ 
				snakeTutorial.removeEverything();
			});
			Networking.socialNetworker.publishFirstGame(Misc.SNAKE_GAME, getOppName()); //FB pubishes "I started playing Snake Battle game at Winner's Way."
		}
		
		override protected function finishGame(message:Message, jackpotWin:Boolean = false):void
		{
			Networking.client.stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
			Misc.delayCallback(function():void
			{
				var snapshotContainer:Sprite = new Sprite(); //no snapshoting of UI-elements
				snapshotContainer.addChild(_snakeField);
				snapshotContainer.addChild(_topField);	
				addChild(snapshotContainer);
				_lastScreenshot = Misc.snapshot(snapshotContainer, Misc.GAME_AREA_WIDTH, Misc.GAME_AREA_HEIGHT);
				
				createFinishGamePopup(message, jackpotWin);					
				_snakeField.clearUp(); //removes connection listeners, bitmapData, etc
				removeChild(snapshotContainer);
			}, 500);			
		}
		
		override protected function usePowerup(e:RequestEvent):void 
		{
            switch (e.stuff.name)
            {
                case "boost2x":
                    _connection.send("bo2");
                    break;
                case "boost3x":
                    _connection.send("bo3");
                    break;
                case "sevenMines":
                    _snakeField.addSevenMines();
                    break;
                case "grid":
                    _connection.send("gr");
                    break;
                case "missile":
                    _connection.send("mi");
                    break;
            }
		}
		
		public function get topField():TopField { return _topField; } //used by SnakeField to call rocketLauncher
	}
}