package events 
{
	import flash.events.Event;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class RequestEvent extends Event
	{
		private var _stuff:Object;
		
		public static const AVATARS_LINKS_LOADED:String = "avatarLinksLoaded";
		public static const AVATARS_WITH_SEX_LOADED:String = "avatarsWithSexLoaded";
		public static const AVATAR_WITH_NAME_LOADED:String = "avatarsWithNameLoaded";		
		public static const BALANCE_CHANGED:String = "balanceChanged";
		public static const BOOST_ME:String = "boostMe";
		public static const BUY_POWERUP:String = "buyPowerup";
		public static const CHANGE_GAME:String = "changeGame";
		public static const COINS_ADDED:String = "coinsAdded";		
		public static const DONT_WANNA_PLAY:String = "dontWannaPlay";	
		public static const ERROR:String = "error";
		public static const ERROR_AT_ADDING_COINS:String = "errorAtAddingCoins";
		public static const EXACTLY_CELL:String = "exactlyCell";
		public static const FRIENDS_LOADED:String = "friendsLoaded";
		public static const IMREADY:String = "imReady";	
		public static const JOIN_GAME:String = "joinGame";
		public static const LAUNCHED:String = "launched";				
		public static const LOADED_LEVEL_MC:String = "loadedLevelMc";		
		public static const LOADED_LOGO:String = "loadedLogo";		
		public static const LOADED_INVITE:String = "loadedInvite";		
		public static const LOADED_GAME_RSL:String = "loadedGameRSL";				
		public static const PERMISSIONS_GRANTED:String = "permissionsGranted";
		public static const PLACE_MINE:String = "placeMine";	
		public static const REMOVE_ME:String = "removeMe";		
		public static const REMOVE_MINE:String = "removeMine";
		public static const SEND_WORD_SELECTED:String = "sendWordSelected";		
		public static const SHOW_COIN_ADDER:String = "showCoinAdder";	
		public static const SHOW_FLASH_COIN_ADDER:String = "showFlashCoinAdder";
		public static const SHOW_FINDING_OPPONENT:String = "showFindingOpponent";
		public static const SHOW_JACKPOT_WIN:String = "showJackpotWin";
		public static const SHOW_JOIN_GAME_POPUP:String = "showJoinGamePopup";
		public static const SHOW_POINT_CHANGE:String = "showPlusPoint";		
		public static const SHOW_SHOP:String = "showShop";		
		public static const SHOW_STREAK_TUTORIAL:String = "showStreakTutorial";
		public static const SHOW_JACKPOT_INFO:String = "showJackpotInfo";
		public static const SHOW_MY_GUYS:String = "showMyGuys";	
		public static const LOADED_SNAKE_TUTORIAL:String = "snakeTutorialLoaded";
		public static const LOADED_STACK_UP_TUTORIAL:String = "stackUpTutorialLoaded";
		public static const SWITCH_TAB:String = "switchTab";
		public static const TRY_USE_ME:String = "tryUseMe";
		public static const USE_POWERUP:String = "usePowerup";	
		public static const USERS_INFO_LOADED:String = "usersInfoLoaded";
		public static const WAS_USED:String = "wasUsed";	
			
		public function RequestEvent(type:String, stuff:Object = null, bubbles:Boolean = false, cancelable:Boolean = false) 
		{		
			super(type, bubbles, cancelable);		
			_stuff = stuff;
		}		
		
		public function get stuff():Object {return _stuff;}
	}
}