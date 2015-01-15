package lobby
{
    import events.RequestEvent;

    import flash.display.Sprite;
    import flash.events.Event;
    import flash.net.SharedObject;

    import lobby.friends.FriendPanel;
    import lobby.gameStart.GameStart;
    import lobby.jackpot.Jackpot;
    import lobby.myWay.MyWay;
    import lobby.myWay.MyWayButton;
    import lobby.powerupsInfo.PowerupsInfo;
    import lobby.shop.Shop;
    import lobby.spiral.LosersSpiral;
    import lobby.spiral.SpiralButton;
    import lobby.userInfo.UserInfo;

    import playerio.Connection;
    import playerio.Message;

    import popups.JackpotInfo;
    import popups.StatePopup;
    import popups.tutorial.JackpotTutorial;
    import popups.tutorial.SpiralTutorial;
    import popups.tutorial.TryOtherGamesTutorial;
    import popups.tutorial.WTFStoryOne;

    import visual.Visual;

    /**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class Lobby extends Sprite
	{
		private var _gameName:String;
		private var _rslCallbackFinished:Boolean = true;
		private var _friendsPanel:FriendPanel;
		private var _powerupsInfo:PowerupsInfo;
		private var _jackpot:Jackpot;
		private var _userInfo:UserInfo;
		private var _myWay:MyWay;
		private var _gameStart:GameStart;
		private var _sharedObject:SharedObject;		
		private var _spiralBtn:SpiralButton;
		private var _popup:Sprite;
		private var _myWayBtn:MyWayButton;
		private var _loadingAnim:StatePopup;
		
		public function Lobby(showStory:Boolean = false) 
		{
			SoundManager.stopBackground();			
			
			_sharedObject = SharedObject.getLocal(Misc.SHARED_OBJECT_NAME);			
			_gameName = _sharedObject.data.lastGameName;
			
			_userInfo = new UserInfo();
			addChild(_userInfo);	
			
			_myWayBtn = new MyWayButton();
			_myWayBtn.addEventListener(RequestEvent.IMREADY, showMyStory);			
			addChild(_myWayBtn);
			
			trace("UserData.winCount : " + UserData.winCount);
			
			_spiralBtn = new SpiralButton();
			_spiralBtn.addEventListener(RequestEvent.IMREADY, showSpiral);
			addChild(_spiralBtn);			
			
			_powerupsInfo = new PowerupsInfo(_gameName);
			_powerupsInfo.addEventListener(RequestEvent.SHOW_SHOP, showShop);
			_powerupsInfo.addEventListener(RequestEvent.BUY_POWERUP, function(e:RequestEvent):void { showShop(null, e.target.name); } );
			addChild(_powerupsInfo);
			
			_gameStart = new GameStart(_gameName);
			_gameStart.addEventListener(RequestEvent.IMREADY, showLoading);
			_gameStart.addEventListener(RequestEvent.CHANGE_GAME, changeGame);
			addChild(_gameStart);
			
			_jackpot = new Jackpot();
			_jackpot.addEventListener(RequestEvent.SHOW_JACKPOT_INFO, showJackpotInfo);
			addChild(_jackpot);
			
			_friendsPanel = new FriendPanel();
			addChild(_friendsPanel);
			
			addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void { tryCreateStoryAndTutorials(showStory); } );
			
			RSLLoader.eventDispatcher.addEventListener(RequestEvent.LOADED_GAME_RSL, onRSLLoaded);
			tryLoadGameRSL();
		}			
		
		public function tryLoadGameRSL():void
		{
			trace("RSLLoader.rslExists: " + RSLLoader.rslExists(_gameName) + " _gameName: " + _gameName);
			if (!(RSLLoader.rslExists(_gameName)))
			{
				if (_rslCallbackFinished) //previous game loading hasn't finished
				{
					_rslCallbackFinished = false;
					RSLLoader.tryLoad(_gameName);
				}
				else Misc.delayCallback(tryLoadGameRSL, 300);
			}
		}
		
		private function onRSLLoaded(e:RequestEvent):void 
		{
			_rslCallbackFinished = true;
			trace("RSL for " + _gameName + " loaded.");
		}
		
		private function tryCreateStoryAndTutorials(showStory:Boolean):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, function(e:Event):void{});
			if (showStory)
                showMyStory();
			
			if (UserData.winCount == Misc.WINS_TO_UNLOCK_SPIRAL && (!UserData.openedSpiral)) //if opened spiral + this is the first time lobby is created with 10 wins
			{
				if (showStory)
                    _myWay.addEventListener(RequestEvent.REMOVE_ME, showSpiralPopup); //show tutorial popup only after closing "myStory"
				else
                    showSpiralPopup();
			}			
			else if (UserData.winCount == Misc.WINS_TO_UNLOCK_JACKPOT && (!UserData.openedJackpot)) //if opened spiral + this is the first time lobby is created with 10 wins
			{
				if (showStory)
                    _myWay.addEventListener(RequestEvent.REMOVE_ME, showJackpotPopup); //show tutorial popup only after closing "myStory"
				else
                    showJackpotPopup();
			}			
			else if (UserData.winCount == Misc.WINS_TILL_OTHER_GAMES_POPUP && (!UserData.triedOtherGames)) //if opened spiral + this is the first time lobby is created with 10 wins
			{
				if (showStory)
                    _myWay.addEventListener(RequestEvent.REMOVE_ME, showTryOtherGamesPopup); //show tutorial popup only after closing "myStory"
				else
                    showTryOtherGamesPopup();
			}
			else if (UserData.winCount == Misc.WINS_TILL_STORY_POPUP && (!UserData.seenStoryTutorial))
			{
				if (showStory)
                    _myWay.addEventListener(RequestEvent.REMOVE_ME, showStoryPopup); //show tutorial popup only after closing "myStory"
				else
                    showStoryPopup();
			}
		}
		
		private function showStoryPopup(e:RequestEvent = null):void 
		{			
			_popup = new WTFStoryOne();
			addChild(_popup);
		}
		
		private function showTryOtherGamesPopup(e:RequestEvent = null):void 
		{						
			_popup = new TryOtherGamesTutorial();
			_gameStart.addEventListener(RequestEvent.CHANGE_GAME, removeOtherGamesPopup);
			addChild(_popup);
		}
		
		private function removeOtherGamesPopup(e:RequestEvent):void 
		{
			_gameStart.removeEventListener(RequestEvent.CHANGE_GAME, removeOtherGamesPopup);
			removeChild(_popup);
			addSolutionListeners();
		}
		
		private function addSolutionListeners():void 
		{
			_gameStart.addEventListener(RequestEvent.IMREADY, function(e:RequestEvent):void { Networking.trySend("tOG", 1); }); //user decided to play the game he switched to
			_gameStart.addEventListener(RequestEvent.CHANGE_GAME, sendForcedChange); //user switched back to game he was playing 
		}
		
		private function sendForcedChange(e:RequestEvent):void 
		{
			_gameStart.removeEventListener(RequestEvent.CHANGE_GAME, sendForcedChange);
			Misc.delayCallback(function():void { Networking.trySend("tOG", 2); }, 10000); //need to connect to the room first (in 10 secs it's very likely that dude will be connected)
		}
		
		private function showJackpotPopup(e:RequestEvent = null):void 
		{			
			_jackpot.mc.gotoAndStop(2);
			_jackpot.createDudes();
			var jackpotPopup:JackpotTutorial = new JackpotTutorial(_jackpot.x, _jackpot.y);
			jackpotPopup.addEventListener(RequestEvent.REMOVE_ME, function(e:RequestEvent):void { removeChild(jackpotPopup); } );
			addChild(jackpotPopup);
		}
		
		private function showSpiralPopup(e:RequestEvent = null):void 
		{			
			_spiralBtn.mc.gotoAndStop(2);
			var spiralPopup:SpiralTutorial = new SpiralTutorial(_spiralBtn.x, _spiralBtn.y);
			_spiralBtn.addEventListener(RequestEvent.IMREADY, function(e:RequestEvent):void { if (contains(spiralPopup)) removeChild(spiralPopup);	} );
			addChild(spiralPopup);
		}
		
		private function changeGame(e:RequestEvent):void 
		{					
			_gameName = e.stuff.name;
			_sharedObject.data.lastGameName = _gameName;	
			_sharedObject.flush();
			_powerupsInfo.switchGame(e.stuff.name);
			
			Networking.trySend("change", _gameName);
			tryLoadGameRSL();
		}
		
		private function showLoading(e:RequestEvent):void 
		{
			_loadingAnim = new StatePopup(true);			
			addChild(_loadingAnim);
			findCreateRoom();				
		}
		
		private function findCreateRoom(message:Message = null):void //it may me called with message callback & without
		{
			trace(message);
			trace("findCreateRoom");
			if (Networking.secondConnection != null) Networking.secondConnection.removeMessageHandler("rc", findCreateRoom);
			trace(Networking.connection);
			
			if (Networking.connection != null) //Making sure connection is saved: if created the room that was selected + joined a room (check for insta-click after gameLoaded).
			{
				if (RSLLoader.rslExists(_gameName)) //second check for RSL being loaded. _rslLoaded = true means that last loading was successful
				{
					if (_gameName == Misc.SNAKE_GAME || _gameName == Misc.WORD_SEEKERS_GAME)
                    {
                        dispatchGotoGame();
                    }
					else
                    {
                        tryFindOpponent();
                    }
				}
				else
				{
					trace("RSL for " + _gameName + " doesn't exist. Loading it");
					tryLoadGameRSL();
					Misc.delayCallback(findCreateRoom, 1000); //wait until rsl is loaded	
				}
			}
			else Misc.delayCallback(findCreateRoom, 500); //wait until connected to other room		
		}		
		
		private function tryFindOpponent():void 
		{
			Networking.client.multiplayer.listRooms(Networking.ROOMTYPE, {game:_gameName, friendly:"false"}, 1, 0, function(rooms:Array):void
			{
				trace("Rooms loaded: " + rooms.length);
				if (rooms.length > 0) //if there is a visible room here
				{
                    trace("found room with id: " + rooms[0].id + " and my id is: " + Networking.client.connectUserId);
					Networking.client.multiplayer.joinRoom(rooms[0].id, null, onJoinedOtherRoom, Misc.handleError);  //random - so not 1st room in list but any
				}
				else
                {
                    dispatchGotoGame();
                } //make our room visible for other dudes & create game
			}, Misc.handleError); 
		}
		
		private function dispatchGotoGame():void
		{
			trace("goVisible");
			Networking.trySend("goVisible", Visual.spacePressed);
			dispatchEvent(new RequestEvent(RequestEvent.JOIN_GAME, { connection:Networking.connection, name:_gameName }));	
		}
		
		private function onJoinedOtherRoom(connection:Connection):void 
		{
			processRoomJoin(connection);
		}
		
		private function processRoomJoin(connection:Connection):void //connected to other dude's room
		{
			trace("joined a room");
			Networking.trySend("oth"); //means connecting to the other room. On next gameStart at server in player's room refresh() will be called on player object (because it'll be changes in a 2nd room)
			Networking.secondConnection = connection;
			Networking.secondConnection.addMessageHandler("rc", findCreateRoom); //if we are asked to reconnect - that create new room, insta. No need 2 seek for more rooms.
			dispatchEvent(new RequestEvent(RequestEvent.JOIN_GAME, { connection:Networking.secondConnection, name:_gameName }));			
		}
		
		private function showJackpotInfo(e:RequestEvent):void 
		{
			var popup:JackpotInfo = new JackpotInfo();
			popup.addEventListener(RequestEvent.REMOVE_ME, function():void { removeChild(popup) } );
			addChild(popup);
		}
		
		private function showShop(e:RequestEvent = null, powerupName:String = ""):void 
		{
			var shop:Shop = new Shop(_gameName, powerupName);
			shop.addEventListener(RequestEvent.REMOVE_ME, function():void {
				_userInfo.updateTextFields();
				_powerupsInfo.updateAmounts();
				removeChild(shop) } );
			addChild(shop);
		}
		
		private function showSpiral(e:RequestEvent):void 
		{
			var spiral:LosersSpiral = new LosersSpiral();
			spiral.addEventListener(RequestEvent.REMOVE_ME, function():void {
				if (spiral.addItemTimer != null && spiral.addItemTimer.running) spiral.addItemTimer.reset();
				removeChild(spiral) } );		
			addChild(spiral);
		}		
		
		public function showMyStory(e:Event = null):void 
		{
			if (_popup != null && contains(_popup)) removeChild(_popup);
			_myWay = new MyWay(_popup != null);
			_myWay.addEventListener(RequestEvent.REMOVE_ME, function():void { removeChild(_myWay) } );
			addChild(_myWay);
		}
		
		public function get userInfo():UserInfo {	return _userInfo;}		
		public function get powerupsInfo():PowerupsInfo {	return _powerupsInfo;	}		
		public function get loadingAnim():StatePopup {	return _loadingAnim;}		
		public function get gameName():String {	return _gameName;}
		public function set gameName(value:String):void {	_gameName = value;		}
	}
}