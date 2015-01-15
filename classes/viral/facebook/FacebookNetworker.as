package viral.facebook 
{
    import com.facebook.graph.Facebook;

    import events.RequestEvent;

    import flash.events.EventDispatcher;
    import flash.external.ExternalInterface;

    import playerio.PlayerIOError;

    import viral.ISocial;

    /**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class FacebookNetworker implements ISocial
	{		
		public const ACRONYM:String = Networking.FB;
		public const GAME_ID:String = "winners-way-fb-rl3wvjarykcscflu8gjnxg";
		public var offers:Array = [];
		public var eventDispatcher:EventDispatcher = new EventDispatcher();
		public var coreLink:String = "https://www.facebook.com/"; //link that is used to navigate to profile pages after clicking on avatar
		public var photoUploader = PhotoUploaderFB; //Networking.socialNetworker.photoUploader is the permanent link to PhotoUploader for any social network
		public var wallPoster = WallPosterFB; //Networking.socialNetworker.wallPoster is the permanent link to WallPoster for any social network
		public var coinsRequested:int = 0;
		
		public function FacebookNetworker() //1 powerup ~ 9-10 cents
		{
			offers[0] = { coins:300, price:10 }; 
			offers[1] = { coins:650, price:20 };
			offers[2] = { coins:1650, price:50 };
			offers[3] = { coins:3400, price:100 }; 
			offers[4] = { coins:6900, price:200 };
			offers[5] = { coins:17500, price:500 };
			
			ExternalInterface.addCallback("requestOfferData", requestOfferData);
			
			RSLLoader.assignLinks("fb");
		}
		
		public function init(flashVars:Object):void
		{
			trace("initialising with: " + flashVars.fb_application_id);
			UserData.id = flashVars.fb_user_id;
			Facebook.init(flashVars.fb_application_id, null, null, flashVars.fb_access_token);
			
			t.obj(flashVars);
		}	
		
		public function getUserData():void
		{
			Facebook.api("/" + UserData.id + "?fields=first_name&", receiveDataFromSocial);
			photoUploader.updatePermissions();
		}
		
		private static function receiveDataFromSocial(...params):void
		{
			t.obj(params);
			trace(params[0]);
			if (params[0]) UserData.saveUserData(params[0].first_name, getPhotoURLByID(params[0].id));
			else trace("Error while getting social data");
		}
		
		public function getPhotoAndName(userID:String):void
		{
			Facebook.api("/" + userID + "?fields=first_name&", function(...params):void
			{
				eventDispatcher.dispatchEvent(new RequestEvent(RequestEvent.AVATAR_WITH_NAME_LOADED, { name:params[0].first_name, photo:getPhotoURLByID(userID) }));
			});
		}
		
		public function getUserFriends():void //get friends & the ones who installed will have "installed" property = true
		{
			trace("getting friends for: " + UserData.id);
			Facebook.api("/" + UserData.id + "/friends?fields=installed&", receiveFriends);
		}
		
		private function receiveFriends(...params):void 
		{			
			trace("receiveFriends");			
			var toLoad:Array = []; //ids of guys whose names should be loaded (loading names of only those friends who installed the app)
			for each (var friend:Object in params[0]) if (friend.installed) toLoad.push(friend.id);		
			if (toLoad.length > 0) //if there are inApp friends
			{
				eventDispatcher.addEventListener(RequestEvent.FRIENDS_LOADED, function(e:RequestEvent):void { onInAppLoaded(e.stuff.users, params[0]); } );
				getUsersNamesAndPhotos(toLoad);
			}
			else onInAppLoaded(toLoad, params[0]); //pass empty InApp array & all friends
		}
		
		private static function onInAppLoaded(inApp:Array, allFriends:Array):void
		{
			for (var i:int = 0; i < allFriends.length; i++) //substitute id-only friends with new objects with name, id, photoUrl & inApp
			{
				for (var j:int = 0; j < inApp.length; j++) 
				{
					if (allFriends[i].id == inApp[j].id) allFriends[i] = inApp[j]; //app user whose name was loaded
				}
			}
			
			for (i = 0; i < allFriends.length; i++)
			{				
				if (allFriends[i].name == null)
                    allFriends[i] = {id:allFriends[i].id, name:"noname", photoURL:getPhotoURLByID(allFriends[i].id), inApp:false}; //insert default obj
			}			
			
			UserData.friends = allFriends;
		}
		
		public function getUsersNamesAndPhotos(usersIDS:Array):void
		{
			trace("getUsersInfo");
			var resultArray:Array = [];
			var deletedCount:int = 0; //if guys do not exist counter is incremented
			t.obj(usersIDS);
			
			for (var i:int = 0; i < usersIDS.length; i++) 
			{
				Facebook.api("/" + usersIDS[i].toString() + "?fields=first_name&", function(...params):void //need only name & id
				{  
					if (params != null && params[0]) resultArray.unshift( { id:params[0].id, name:params[0].first_name, photoURL:getPhotoURLByID(params[0].id), inApp:true } );			
					else 
					{
						trace("Error while getting social data");
						deletedCount++;
					}
					if ((resultArray.length + deletedCount) == usersIDS.length)
					{
						eventDispatcher.dispatchEvent(new RequestEvent(RequestEvent.USERS_INFO_LOADED, { users:resultArray } )); //for other classes
						eventDispatcher.dispatchEvent(new RequestEvent(RequestEvent.FRIENDS_LOADED, { users:resultArray } )); //for onInAppLoaded function
					}
				});			
			}
		}
		
		public function getAvatarLinks(usersIDS:Array):void
		{
			var resultArray:Array = [];
			for (var j:int = 0; j < usersIDS.length; j++) 
			{
				resultArray[j] = { uid:usersIDS[j], photo:getPhotoURLByID(usersIDS[j]) };
			}
			eventDispatcher.dispatchEvent(new RequestEvent(RequestEvent.AVATARS_LINKS_LOADED, { users:resultArray } ));
		}
		
		public function getPhotoAndSexAndName(userID:String):void
		{			
			Facebook.api("/" + userID + "?fields=first_name&", function(...params):void
			{
				var result:Object = { uid:userID, photo:getPhotoURLByID(userID), sex:0, name:params[0].first_name }; //don't care about sex on english version				
				eventDispatcher.dispatchEvent(new RequestEvent(RequestEvent.AVATARS_WITH_SEX_LOADED, result ));				
			});			
		}		
		
		private static function getPhotoURLByID(id:String):String
		{
			return "https://graph.facebook.com/" + id + "/picture";
		}
		
		public function showFriendInvite(uid:String):void
		{
			Facebook.ui('apprequests', { to:uid, message: "Let's play some real-time arcades together!" } );
		}
		
		public function showCoinAdder():void //send to JS -> navigate to "Buy coins" tab
		{
			ExternalInterface.call("showTab", "coins");
		}
		
		public function requestOfferData(offerID:int):void
		{
			coinsRequested = offers[offerID].coins;
			trace("wanna buy: " + offers[offerID].coins + " for: " + offers[offerID].price);  //e.g. 2 credits
			Networking.client.payVault.getBuyCoinsInfo(
				"facebookv2",		//Provider name
				{				//Purchase arguments								
					coinamount:offers[offerID].coins.toString(),							
					title:offers[offerID].coins.toString() + " Coins",
					description:offers[offerID].coins.toString() + " Coins in Winner's Way Game",
					image:"https://r.playerio.com/r/gameclub-keir6opw40azy8e8klqtia/GameClub%20Facebook%20App/images/coin.gif",
					currencies:"USD"
				},
				showPayDialog, function(e:PlayerIOError):void { trace("Unable to buy coins", e) ; }	
			);		
		}
		
		private function showPayDialog(info:Object):void 
		{
			t.obj(info);
			var newInfo:Object = { order_info:info.order_info, purchase_type:info.purchase_type, dev_purchase_params: { 'oscif': true } }; //adding dev_purchase_params & removing "method" property
			t.obj(newInfo);
			Facebook.ui('pay', info, onCoinsAdded);
		}
		
		private function onCoinsAdded(data:Object):void
		{
			if (data.payment_id)
			{
				trace("Purchase completed!"); 
				UserData.coins += coinsRequested;
				eventDispatcher.dispatchEvent(new RequestEvent(RequestEvent.BALANCE_CHANGED));
			}
			else
                trace("Credits purchase failed");
			
			ExternalInterface.call("showTab", "play");
		}
		
		public function getOpponentInfo(playerObj:Object):void
		{		
			Facebook.api("/" + playerObj.id + "?fields=first_name&", function(...params):void { dispatchNewPlayerObject(params, playerObj); } );
		}
		
		private function dispatchNewPlayerObject(params:Array, playerObj:Object):void 
		{
			trace("gotOpponent info");
			t.obj(params);
			t.obj(playerObj);
			if (params[0])
			{				
				playerObj.photoURL = getPhotoURLByID(params[0].id);
				playerObj.name = params[0].first_name;							
				playerObj.insname = params[0].first_name; //in Russian language it differs from "name"
				eventDispatcher.dispatchEvent(new RequestEvent(RequestEvent.IMREADY, playerObj)); //don't need to wait until next api call will be responded. Need it only at  gameFinish		
			}
			else //setting default values while development
			{
				trace("Error while getting social data");			
				playerObj.photoURL = "https://graph.facebook.com/zuck/picture";
				playerObj.name = "Zuck";
				playerObj.insname = "Zuck";
				eventDispatcher.dispatchEvent(new RequestEvent(RequestEvent.IMREADY, playerObj)); //don't need to wait until next api call will be responded. Need it only at  gameFinish		
			}
		}
		
		public function getRoomLink():String
		{
			return "https://apps.facebook.com/winnersway?join=" + UserData.id;
		}
		
		public function showSocialInvitePopup():void
		{
			ExternalInterface.call("showFriendInviter");
		}
		
		public function publishFirstGame(gameName:String, oppName:String):void
		{
			Misc.delayCallback(function():void
			{
				trace("publishFirstGame");
				if (oppName == null || oppName == "" || oppName == "undefined" || oppName == "empty") oppName = "Mister X";
				var message:String = UserData.name + " started playing " + Misc.getFullGameName(gameName) + " with " + oppName + ".";			
				WallPosterFB.doSimplePost(message);
			}, 10000); //so opps name definitely will load
		}
		
		public function publishPlayedGameAction(gameName:String):void 
		{
			trace("going to publish action for game: " + gameName);
			var objectURL:String = "";
			switch (gameName) 
			{
				case Misc.SNAKE_GAME:
					objectURL = "https://apps.facebook.com/winnersway/fbObjects/snakeGame.html";
					break;
				case Misc.STACK_UP_GAME:
					objectURL = "https://apps.facebook.com/winnersway/fbObjects/stackUpGame.html";
					break;
				case Misc.WORD_SEEKERS_GAME:
					objectURL = "https://apps.facebook.com/winnersway/fbObjects/wordSeekersGame.html";
					break;	
			}
			Facebook.api("/me/winnersway:play", onPublishedAction, { game : objectURL }, "POST");
		}
		
		private static function onPublishedAction(...params):void
		{
			t.obj(params);
		}
	}
}