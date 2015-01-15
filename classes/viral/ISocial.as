package viral 
{
	
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public interface ISocial 
	{
		function init(flashVars:Object):void;
		
		///These may be united in 1 more complicated method///
		/**
		 * Gets name & photo of user who launched the app
		 */
		function getUserData():void;
		
		/**
		 * Gets friends (including inApp friends) of user who launched the app
		 */
		function getUserFriends():void;
		
		/**
		 * Gets links to avatars for desired users. Dispatches through eventDispatcher array of objects (with "uid", "photo" properties)
		 */
		function getAvatarLinks(uidArray:Array):void; 
		
		/**
		 * Gets photo, sex and name for target uid
		 */
		function getPhotoAndSexAndName(userID:String):void;
		
		/**
		 * Gets names & photos for a bunch of users (for TOP100 likes)
		 */
		function getUsersNamesAndPhotos(usersIDS:Array):void;
		
		/**
		 * This function is called when getting social info about user's opponent. 
		 */
		function getOpponentInfo(playerObj:Object):void;
		
		/**
		 * Gets name (at VK in accusative) and photo of "liker" when showing Like popup
		 */
		function getPhotoAndName(userID:String):void;
		
		/**
		 * Show social network popup. At VK uploads Logo to make social popup. 
		 */
		function showFriendInvite(uid:String):void;
		
		/**
		 * At FB user is redirected to Coins purchase HTML page
		 */
		function showCoinAdder():void;
		
		/**
		 * Gets coint amount, price in Social Network Currency
		 */
		function requestOfferData(offerID:int):void;	
		
		/**
		 * Gets room link for friend inviting.
		 */
		function getRoomLink():String;
		
		/**
		 * Show multi-friend invite popup of social network
		 */
		function showSocialInvitePopup():void;
		
		/**
		 * FB published "I started playing [gamename] at Winner's Way."
		 */
		function publishFirstGame(gameName:String, oppName:String):void;
		
		/**
		 * FB published "I played [gamename] at Winner's Way" as action
		 */
		function publishPlayedGameAction(gameName:String):void;
	}	
}