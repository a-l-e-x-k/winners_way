package  
{
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class UserData 
	{
		public static var id:String = ""; //social network id
		public static var friends:Array; //frieds objects with properties: id, name(for inApp only), photoURL, inApp:Boolean
		public static var name:String = "";
		public static var photoURL:String = "";
		public static var permissions:Object; //used when uploading photo/wallpost (so there is no need to wait for SNS-response)
		public static var winCount:int = -1;
		public static var coins:int = 1000;
		public static var streak:Array = [];		
		public static var openedJackpot:Boolean = false;
		public static var openedSpiral:Boolean = false;
		public static var openedSnake:Boolean = false; //by opening snake you open powerups also
		public static var openedWordSeekers:Boolean = false;
		public static var openedStackUp:Boolean = false;
		public static var openedStreak:Boolean = false;	
		public static var triedOtherGames:Boolean = false;
		public static var seenStoryTutorial:Boolean = false;
		public static var seenPopup:Boolean = true; //thus if user visits app 1st time he wont seen popup
		public static var seenMarchPopup:Boolean = false;
		
		public static function setDefaults():void
		{
			var story:Array = [];
			winCount = 0;
			for (var i:int = 1; i < 11; i++) story.push([]);
			//story[1] =  ["123-f", "213-f", "124-f", "4263-f", "111-f"];
			//story[2] =  ["1231-f", "1234-f", "777-f", "1", "2-f", "3-f"];
			//story[3] =  ["10-f", "11-f", "12", "13-f", "899-f"];
			StoryManager.story = story;
			StoryManager.calculateMyCurrentLevel();
		}
		
		public static function saveUserData($name:String, $photoURL:String):void
		{
			name = $name;	
			photoURL = $photoURL;
			if (Main._visual != null && Main._visual.lobby != null && Main._visual.contains(Main._visual.lobby)) Main._visual.lobby.userInfo.showPhotoName();  	
		}
	}
}