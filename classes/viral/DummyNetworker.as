package viral 
{
	import events.RequestEvent;
	import flash.events.EventDispatcher;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class DummyNetworker implements ISocial 
	{
		public const ACRONYM:String = "local";//Networking.LOCAL;
		public const GAME_ID:String = "winners-way-fb-rl3wvjarykcscflu8gjnxg";
		public var offers:Array = [];
		public var eventDispatcher:EventDispatcher = new EventDispatcher();
		public var coreLink:String = "https://www.facebook.com/"; //link that is used to navigate to profile pages after clicking on avatar
		public var photoUploader;
		public var wallPoster;
		
		public function DummyNetworker() 
		{
			RSLLoader.assignLinks("local");
			
			offers[0] = { coins:300, price:3 };
			offers[1] = { coins:600, price:5 }; //+50 free
			offers[2] = { coins:1250, price:10 }; //+50 free
			offers[3] = { coins:2600, price:20 }; //+70 free
			offers[4] = { coins:6600, price:50 }; //+100 free
			offers[5] = { coins:14000, price:100 }; //+300 free
		}
		
		public function init(flashVars:Object):void
		{
			UserData.id = Misc.randomNumber(99999).toString();//"73920149";//
			UserData.photoURL = "https://graph.facebook.com/zinderlex/picture";
            UserData.name = "Alex";
            UserData.friends = [];
		}
		
		public function getUserData():void {}
		
		public function getUserFriends():void {}
		
		public function getUsersNamesAndPhotos(usersIDS:Array):void
        {
            var result:Array = [];
            for (var i:int = 0; i < usersIDS.length; i++)
            {
                result.push({
                            id:usersIDS[i],
                            name:"Sim_" + i,
                            photoURL:"https://graph.facebook.com/zuck/picture"});
            }
            eventDispatcher.dispatchEvent(new RequestEvent(RequestEvent.USERS_INFO_LOADED, { users:result } ));
        }
		
		public function getAvatarLinks(uidArray:Array):void 
		{ 
			var resultArray:Array = [];
			for (var j:int = 0; j < uidArray.length; j++) 
			{
				resultArray[j] = { uid:uidArray[j], photo:UserData.photoURL };
			}
			eventDispatcher.dispatchEvent(new RequestEvent(RequestEvent.AVATARS_LINKS_LOADED, { users:resultArray } ));
		}
		
		public function getPhotoAndSexAndName(userID:String):void {  }
		
		public function getPhotoAndName(userID:String):void {}
		
		public function showFriendInvite(uid:String):void {	}
		
		public function getOpponentInfo(playerObj:Object):void 
		{
			playerObj.photoURL = "https://graph.facebook.com/zinderlex/picture";
			playerObj.name = "Alex";		
			playerObj.insname = "Alex";
			eventDispatcher.dispatchEvent(new RequestEvent(RequestEvent.IMREADY, playerObj));		
		}		
		
		public function showCoinAdder():void {	}		
		
		public function requestOfferData(offerID:int):void{			}
		
		public function getRoomLink():String { return "http://link";  }
		
		public function showSocialInvitePopup():void
		{
			trace("showing popup");
		}
		
		public function publishFirstGame(gameName:String, oppName:String):void { }
		
		public function publishPlayedGameAction(gameName:String):void {}
	}
}