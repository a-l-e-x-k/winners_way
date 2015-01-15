package visual
{
	import events.RequestEvent;
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import games.Game;
	import games.snake.SnakeGame;
	import games.stackUp.StackUpGame;
	import games.wordSeekers.WordSeekers;
	import lobby.Lobby;
	import lobby.slotMachine.SlotMachine;
	import playerio.DatabaseObject;
	import popups.StatePopup;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public class Visual extends Sprite
	{
		public static var spacePressed:Boolean = false;
		protected var _lobby:Lobby; //used by Misc to determine whether lobby was created or not (when loading likes)	
		protected var _connectingToFriendPopup:StatePopup;
		protected var _betweenGamesSceenshot:Bitmap; //used at friendly visual when connecting between games. ("playing again")
		private var _game:Game;	
		private var _visual:Visual;
        private var _bgMC:MovieClip;
		
		public function Visual()
		{
            _visual = this;

            _bgMC = new backgroundMC();
            _bgMC.anim_mc.message_txt.text = Lingvo.dictionary.connecting();
            addChild(_bgMC);

			var mask:Shape = Misc.createRectangle(Misc.GAME_AREA_WIDTH + 1, Misc.GAME_AREA_HEIGHT + 1, 0, 0);
			addChild(mask);
			this.mask = mask;

			addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		
		public function tryCreateSlotMachine(dbObj:DatabaseObject):void
		{
			var nowDay:Number = new Date().dateUTC;					
			var lastDay:int = dbObj.lastDay;		
			
			if (nowDay != lastDay) //If equal - not the first visit today. if user cheats & changes date then it's visual change only. Items are added to payVault at serverside.
			{
				var slotMachine:SlotMachine = new SlotMachine(dbObj.nga, lastDay); //new Sprite() -> cause there is nothing 2 blur
				slotMachine.addEventListener(RequestEvent.REMOVE_ME, function(e:RequestEvent):void {
					removeChild(slotMachine);
					createLobby();
					_bgMC.removeChild(_bgMC.anim_mc);
				});							
				addChild(slotMachine);
			}
			else
			{
				createLobby();
                _bgMC.removeChild(_bgMC.anim_mc);
			}					 
		}
		
		public function createLobby(e:RequestEvent = null):void 
		{	
			SoundManager.stopBackground();
            tryCleanGame();
			_lobby = new Lobby(e != null && e.stuff != null && e.stuff.showFullStory);
			_lobby.addEventListener(RequestEvent.JOIN_GAME, createGame);
			addChild(_lobby);
		}	
		
		protected function createGame(e:RequestEvent):void 
		{
            tryCleanGame();
			
			if (e.stuff.name == Misc.WORD_SEEKERS_GAME)
                _game = new WordSeekers(e.stuff.connection, e.stuff.name);  //create game and wait until it loads all the data (+ show "Loading")
			else if (e.stuff.name == Misc.SNAKE_GAME)
                _game = new SnakeGame(e.stuff.connection, e.stuff.name);
			else if (e.stuff.name == Misc.STACK_UP_GAME)
                _game = new StackUpGame(e.stuff.connection, e.stuff.name);
			
			_game.addEventListener(RequestEvent.SHOW_FINDING_OPPONENT, showFindingOpponent);
			_game.addEventListener(RequestEvent.LOADED_GAME_RSL, processGameReady); //we add new 	
			_game.addEventListener(RequestEvent.JOIN_GAME, createGame); //if too long connect..				
			_game.addEventListener(RequestEvent.REMOVE_ME, createLobby); //when game finished			
		}
		
		private function showFindingOpponent(e:RequestEvent):void 
		{
			_lobby.loadingAnim.findingopponent();
			_lobby.loadingAnim.addEventListener(RequestEvent.REMOVE_ME, removeLoadingPopup);
		}
		
		private function removeLoadingPopup(e:RequestEvent):void 
		{
			_lobby.removeChild(_lobby.loadingAnim);
		}
		
		private function processGameReady(e:RequestEvent):void 
		{
			trace("game ready");
			if (_betweenGamesSceenshot != null) _betweenGamesSceenshot.bitmapData.dispose();
			Misc.tryRemoveObject(_connectingToFriendPopup, this);
			Misc.tryRemoveObject(_connectingToFriendPopup, this);
			Misc.tryRemoveObject(_lobby, _visual);
			addChild(_game);
		}
				
		private function onAdded(e:Event):void 
        {
			stage.addEventListener(KeyboardEvent.KEY_DOWN, tryTurnOnSpace);
			stage.addEventListener(KeyboardEvent.KEY_UP, turnOffSpace);
		}	
		
		private static function tryTurnOnSpace(e:KeyboardEvent):void
		{
			if (e.keyCode == Keyboard.SPACE)
                spacePressed = true;
		}
		
		private static function turnOffSpace(e:KeyboardEvent):void
		{
			spacePressed = false;
		}

        private function tryCleanGame():void
        {
            if (_game != null)
            {
                _game.removeEventListener(RequestEvent.SHOW_FINDING_OPPONENT, showFindingOpponent);
                _game.removeEventListener(RequestEvent.LOADED_GAME_RSL, processGameReady); //we add new
                _game.removeEventListener(RequestEvent.JOIN_GAME, createGame); //if too long connect..
                _game.removeEventListener(RequestEvent.REMOVE_ME, createLobby); //when game finished
                Misc.tryRemoveObject(_game, _visual);
            }
        }

		public function get lobby():Lobby {return _lobby;} //used for updating likes & showing photo when loaded
		public function get game():Game {return _game;} //used when showing like, to update like buttons near player items		
        public function get bgMC():MovieClip
        {
            return _bgMC;
        }
    }
}