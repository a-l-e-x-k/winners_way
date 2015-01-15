package viral.vk 
{
	import events.RequestEvent;
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.utils.getDefinitionByName;
	import playerio.Message;
	import viral.ISocial;
	import vk.APIConnection;
	import vk.events.CustomEvent;
	
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public class VKNetworker implements ISocial 
	{		
		public const ACRONYM:String = Networking.VK;
		public const GAME_ID:String = "winners-way-vk-nfj7vrmru6tvlbd2nexia";
		public var VK:APIConnection;
		public var offers:Array = [];		
		public var eventDispatcher:EventDispatcher = new EventDispatcher();
		public var coreLink:String = "http://vk.com/id"; //link that is used to navigate to profile pages after clicking on avatar
		public var photoUploader = PhotoUploaderVK; //Networking.socialNetworker.photoUploader is the permanent link to PhotoUploader for any social network
		public var wallPoster = WallPosterVK; //Networking.socialNetworker.wallPoster is the permanent link to WallPoster for any social network	
		private var _buyingOfferPrice:int;
		
		public function VKNetworker() 
		{
			offers[0] = { coins:300, price:3 };
			offers[1] = { coins:600, price:5 };
			offers[2] = { coins:1250, price:10 }; 
			offers[3] = { coins:2600, price:20 };
			offers[4] = { coins:6600, price:50 };
			offers[5] = { coins:14000, price:100 }; 
			
			RSLLoader.assignLinks("vk");
		}		
		
		public function init(flashVars:Object):void 
		{
			VK = new APIConnection(flashVars);			
			UserData.id = flashVars.viewer_id;
			
			//if (UserData.id == "73920149") Notificator.doConnectionStuff();
			
			if (flashVars.referrer == "wall_view_inline") Networking.fromWall = true;
			else //no stats saving when opening app on wall
			{	
				Misc.delayCallback(function() //connection is null, wait a while
				{
					if (flashVars.referrer == "menu") Networking.trySend("vkr", "menu");
					else if (flashVars.referrer == "wall_post_inline" || flashVars.referrer == "wall_post") Networking.trySend("vkr", "wp");
					else if (flashVars.referrer == "catalog_visitors") Networking.trySend("vkr", "cat");
					else if (flashVars.referrer == "featured") Networking.trySend("vkr", "myapps");
					else Networking.trySend("vkr", "l");
				}, 15000);
			}			
		}		
		
		public function getUserData():void 
		{
			VK.api("getProfiles", { uids:UserData.id, fields:"photo_medium_rec,first_name" }, function(response:Array)			
			{
				//t.obj(response);
				UserData.saveUserData(response[0].first_name, response[0].photo_medium_rec);				
			});
		}
		
		public function getUserFriends():void 
		{
			VK.api("friends.getAppUsers", {}, processInApp);			
		}
		
		private function processInApp(response:Array):void 
		{
			//t.obj(response);
			VK.api("friends.get", { uid:UserData.id, fields:"photo_medium_rec,first_name" }, function(responsee:Array)
			{
				//t.obj(responsee);
				saveFriendsData(response, responsee);				
			}, handleVKError);
		}		
		
		private function saveFriendsData(inApp:Array, allFriends:Array):void 
		{			
			var result:Array = [];
			for (var i:int = 0; i < allFriends.length; i++) 
			{				
				result.push( { id:allFriends[i].uid, name:allFriends[i].first_name, photoURL:allFriends[i].photo_medium_rec, inApp:inApp.indexOf(allFriends[i].uid) != -1 } );				
			}			
			UserData.friends = result;
		}		
		
		public function getAvatarLinks(uidArray:Array):void 
		{
			trace("getAvatarLinks");
			var idsString:String = ""; //TODO: add here an execute method (so when > 1000 wins will be handled by multiple requests)				
			var count:int = uidArray.length;
			for (var i:int = 0; i < uidArray.length; i++) 
			{
				idsString += uidArray[i] + (i == (count - 1) ? "" : ",");
			}			
			trace(idsString);
			VK.api("getProfiles", { uids:idsString, fields:"photo_medium_rec" }, saveAvatarsLinks);			
		}
		
		private function saveAvatarsLinks(response:Array):void 
		{
			var resultArray:Array = [];
			for (var j:int = 0; j < response.length; j++) 
			{
				resultArray[j] = { uid:response[j].uid, photo:response[j].photo_medium_rec };
			}
			eventDispatcher.dispatchEvent(new RequestEvent(RequestEvent.AVATARS_LINKS_LOADED, { users:resultArray } ));
		}
		
		public function getPhotoAndSexAndName(userID:String):void 
		{
			VK.api("getProfiles", { uids:userID, fields:"photo_medium_rec,sex,first_name" }, savePhotoSexAndName);	
		}
		
		private function savePhotoSexAndName(response:Array):void 
		{
			var result:Object = { uid:response[0].uid, photo:response[0].photo_medium_rec, sex:response[0].sex, name:response[0].first_name };
			eventDispatcher.dispatchEvent(new RequestEvent(RequestEvent.AVATARS_WITH_SEX_LOADED, result));	
		}
		
		public function getUsersNamesAndPhotos(usersIDS:Array):void 
		{
			trace("getUsersNamesAndPhotos");
			//t.obj(usersIDS);
			var idsString:String = "";
			var count:int = usersIDS.length;
			for (var i:int = 0; i < count; i++) 
			{
				idsString += usersIDS[i] + (i == (count - 1) ? "" : ",");				
			}
			trace("idsString: " + idsString);
			VK.api("getProfiles", { uids:idsString, fields:"first_name, photo_medium_rec" }, saveUsersNames);			
		}
		
		private function saveUsersNames(response:Array):void 
		{
			trace("saveUsersNames");
			//t.obj(response);
			var resultArray:Array = [];
			for (var i:int = 0; i < response.length; i++) 
			{
				resultArray.unshift({ id:response[i].uid, name:response[i].first_name, photoURL:response[i].photo_medium_rec });
			}			
			eventDispatcher.dispatchEvent(new RequestEvent(RequestEvent.USERS_INFO_LOADED, { users:resultArray } )); //for other classes
		}
		
		public function getOpponentInfo(playerObj:Object):void 
		{
			VK.api("getProfiles", { uids:playerObj.id, fields:"first_name", name_case:"ins" }, function(response:Array) { onInsNameLoaded(playerObj, response[0].first_name ); } );;
		}
		
		private function onInsNameLoaded(playerObj:Object, insName:String):void 
		{
			playerObj.insname = insName;
			VK.api("getProfiles", { uids:playerObj.id, fields:"photo_medium_rec,first_name" }, function(response:Array) { dispatchNewPlayerObject(response, playerObj);	});	
		}
		
		private function dispatchNewPlayerObject(response:Array, playerObj:Object):void 
		{
			playerObj.photoURL = response[0].photo_medium_rec;
			playerObj.name = response[0].first_name;
			eventDispatcher.dispatchEvent(new RequestEvent(RequestEvent.IMREADY, playerObj));
		}		
		
		public function getPhotoAndName(userID:String):void 
		{
			VK.api("getProfiles", { uids:userID, fields:"photo_medium_rec,first_name", name_case:"acc" }, dispatchPhotoAndName);				
		}
		
		private function dispatchPhotoAndName(response:Array):void 
		{
			eventDispatcher.dispatchEvent(new RequestEvent(RequestEvent.AVATAR_WITH_NAME_LOADED, { name:response[0].first_name, photo:response[0].photo_medium_rec }));
		}
		
		public function showFriendInvite(uid:String):void 
		{
			var f:Function;
			RSLLoader.eventDispatcher.addEventListener(RequestEvent.LOADED_LOGO, f = function(e:RequestEvent) 
			{ 
				RSLLoader.eventDispatcher.removeEventListener(RequestEvent.LOADED_LOGO, f);
				showWallPost(uid); 
			});
			RSLLoader.tryLoad("logo");
		}
		
		private function showWallPost(uid:String):void 
		{		
			var assetClass:Class = getDefinitionByName("logotypic") as Class;
			var logotype:MovieClip = new assetClass();			
			WallAppPosterVK.wallPicturePost(uid, Misc.snapshot(logotype, 360, 200), Lingvo.dictionary.invitetext());	//note that snapshot size is set manually.		
		}	
		
		public function requestOfferData(offerID:int):void 
		{			
			_buyingOfferPrice = offers[offerID].price; //e.g. 2 votes
			trace("wanna buy: " + offers[offerID].coins + " for: " + _buyingOfferPrice);
			Networking.trySend("wv", Networking.flashVars.auth_key, _buyingOfferPrice);
			Networking.connection.addMessageHandler("notEnough", showSocialNetworkPopup);
			Networking.connection.addMessageHandler("err", dispatchError);
			Networking.connection.addMessageHandler("ok", dispatchOK);
		}
		
		private function showSocialNetworkPopup(message:Message):void 
		{
			trace("notEnough: " + message.getInt(0));
			VK.callMethod("showPaymentBox", message.getInt(0));
			VK.addEventListener("onBalanceChanged", onBalanceChanged);		
		}
		
		private function onBalanceChanged(e:CustomEvent):void
		{
			trace("votes added: " + e.params[0]); //votes in sotye doli
			Networking.trySend("wv", Networking.flashVars.auth_key, _buyingOfferPrice);
		}
		
		private function dispatchOK(message:Message):void 
		{
			UserData.coins += message.getInt(0);
			removeListeners();
			eventDispatcher.dispatchEvent(new RequestEvent(RequestEvent.COINS_ADDED));
		}
		
		private function dispatchError(message:Message):void 
		{
			removeListeners();
			eventDispatcher.dispatchEvent(new RequestEvent(RequestEvent.ERROR_AT_ADDING_COINS));
		}	
		
		private function removeListeners():void 
		{
			Networking.connection.removeMessageHandler("notEnough", showSocialNetworkPopup);
			Networking.connection.removeMessageHandler("err", dispatchError);	
			Networking.connection.removeMessageHandler("ok", dispatchOK);
			VK.removeEventListener("onBalanceChanged", onBalanceChanged);
		}
		
		public function handleVKError(response:Object):void 
		{
			Networking.client.errorLog.writeError(response.error_msg.toString(), "", "", null);
		}
		
		public function showCoinAdder():void 
		{  
			//at Facebook there is page shown to buy coins via JS + HTML. At VK this function ain't called.
		}
		
		public function getRoomLink():String
		{
			return "http://vk.com/winnersway#r=" + UserData.id;
		}
		
		public function showSocialInvitePopup():void
		{
			VK.callMethod("showInviteBox");
		}
		
		public function publishFirstGame(gameName:String, oppName:String):void { };
		public function publishPlayedGameAction(gameName:String):void {};
	}
}