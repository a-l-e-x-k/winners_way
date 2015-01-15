package  
{
    import fl.containers.UILoader;

    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.SharedObject;
    import flash.net.URLRequest;
    import flash.utils.ByteArray;
    import flash.utils.Dictionary;

    import playerio.Client;
    import playerio.Connection;
    import playerio.DatabaseObject;

    import viral.DummyNetworker;

    import visual.InviteHandler;

    //import viral.vk.VKNetworker;
    /**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class Networking
	{
		public static const VK:String = "VK";
		public static const LOCAL:String = "local";
		public static const FB:String = "FB";
		public static const ROOMTYPE:String = "basic";
		public static var client:Client;
		public static var connection:Connection;
		public static var secondConnection:Connection;	
		public static var flashVars:Object;
		public static var eventDispatcher:EventDispatcher = new EventDispatcher();
		public static var avatars:Dictionary = new Dictionary(); //UI loaders for each kind of avatar
		public static var fromWall:Boolean = false;
		public static var socialNetworker:DummyNetworker = new DummyNetworker(); //just substitute it for another VKNetworker when publishing app on VK or DummyNetworker when testing locally
		
		public static function parseFlashvars($flashVars:Object):void
        {
            flashVars = $flashVars;
            socialNetworker.init(flashVars);
        }
		
		public static function saveClient(clientik:Client):void
		{			
			client = clientik;
			if(socialNetworker.ACRONYM == LOCAL)
                client.multiplayer.developmentServer = "192.168.48.176:8184"; //local dev serv in test mode
			
			var sharedObject:SharedObject = SharedObject.getLocal(Misc.SHARED_OBJECT_NAME);			
			if (!sharedObject.data.hasOwnProperty("lastGameName")) 
			{
				sharedObject.data.lastGameName = Misc.GAMES_NAMES[0];	//if there is no property, set snake as default.
				sharedObject.flush(); 
			}
			trace("sharedObject.data.lastGameName:" + sharedObject.data.lastGameName);
			
			client.multiplayer.createJoinRoom(UserData.id, ROOMTYPE, false, {game:sharedObject.data.lastGameName, friendly:"false"}, null, function(connectiona:Connection):void //join pseudo room -> so live updates of any kind will be aviable (e.g. liking guys is story)
			{
				connection = connectiona;
			}, Misc.handleError);
			
			socialNetworker.getUserData();
			socialNetworker.getUserFriends();
		}	
		
		public static function loadPlayerObject(visualMC:InviteHandler):void
		{
			trace("gonna load");
			client.bigDB.loadMyPlayerObject(function(dbObj:DatabaseObject):void
			{	
				trace("plobject loaded");
				if (dbObj.story == null) //first time plobject is being created at server, so need to wait
				{
					UserData.setDefaults();
					PowerupsManager.setDefaults();
					visualMC.createLobby();
					visualMC.bgMC.removeChild(visualMC.bgMC.anim_mc);
				}
				else 
				{
					client.payVault.refresh(function():void
					{
						trace("client.payVault.coins: " + client.payVault.coins);
						UserData.coins = client.payVault.coins;
						PowerupsManager.checkForInfinity(client.payVault);
						PowerupsManager.savePowerups();
						trace("dbObj.story: " + dbObj.story);		
						UserData.streak = dbObj.streak;
						if (dbObj.winCount != null) UserData.winCount = dbObj.winCount;
						UserData.openedSnake = dbObj.oSN == null;
						UserData.openedJackpot = dbObj.oJP == null;
						UserData.openedSpiral = dbObj.oSP == null;
						UserData.openedStackUp = dbObj.oSU == null;
						UserData.openedWordSeekers = dbObj.oWS == null;
						UserData.openedStreak = dbObj.oST == null;
						UserData.triedOtherGames = dbObj.tOG == null;
						UserData.seenStoryTutorial = dbObj.oSO == null;
						UserData.seenPopup = (dbObj.seenPopup != null && dbObj.seenPopup == true);
						UserData.seenMarchPopup = (dbObj.bonus8m != null && dbObj.bonus8m == true);
						StoryManager.story = dbObj.story;
						StoryManager.calculateMyCurrentLevel();
						visualMC.tryCreateSlotMachine(dbObj);
					}, Misc.handleError);						
				}			
			}, Misc.handleError);
		}
		
		public static function getAvatarContainer(link:String, height:int = 50, width:int = 50):UILoader
		{
			var avatar:UILoader = new UILoader();			
			if (link != null) 
			{
				if (avatars[link] == null) 
				{
					var loader:Loader = new Loader();
					loader.load(new URLRequest(link));          					loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
					loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
					loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(evt:Event):void //all that business is to avoid security sandbox violation when loading from some domains without crossdomain.xml. Using not an image but a bytes of it
					{
						var lInfo:LoaderInfo = LoaderInfo(evt.target);
						var ba:ByteArray = lInfo.bytes;
						
						var reloader:Loader = new Loader();
						reloader.loadBytes(ba);
						reloader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
						reloader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
						reloader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(ev:Event):void { reloaderComplete(ev, avatar, link); } );
					});			
				}
				else
				{
					avatars[link].width = width;
					avatars[link].height = height;
					var pic:Bitmap = Misc.snapshot(avatars[link], width, height);					
					pic.name = "pic";
					avatar.addChild(pic);
				}
			}
			else 
			{
				var questionMC:MovieClip = new ssss();
				avatar.addChild(questionMC);
			}
			avatar.height = height;
			avatar.width = width;
			return avatar;
		}
		
		static private function securityErrorHandler(e:SecurityErrorEvent):void 
		{
			trace("SecurityError at loading avatar");
		}
		
		static private function ioErrorHandler(e:Event):void 
		{
			trace("IO Error at loading avatar");
		}
		 
		private static function reloaderComplete(evt:Event, avatar:UILoader, link:String):void
		{
			var imageInfo:LoaderInfo = LoaderInfo(evt.target);
			var bmd:BitmapData = new BitmapData(imageInfo.width,imageInfo.height);
			bmd.draw(imageInfo.loader);
			var resultBitmap:Bitmap = new Bitmap(bmd);
			resultBitmap.width = resultBitmap.height = 50;
			avatar.addChild(resultBitmap);	
			avatars[link] = avatar;
		}
		
		public static function trySend(...args:Array):void
		{
			trace("trying to send: " + args);
			if (connection != null) 
			{
				connection.send.apply(null, args);			
			}
			else Misc.delayCallback(function():void { trySend(args); }, 500);
		}
	}
}