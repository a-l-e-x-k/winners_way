package  
{
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLRequest;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class SoundManager 
	{
		public static const SOUND_FOLDER:String = "http://cdn.playerio.com/gameclub-keir6opw40azy8e8klqtia/sounds/";
		public static const MUSIC_FOLDER:String = "http://cdn.playerio.com/gameclub-keir6opw40azy8e8klqtia/music/";
		public static var sounds:Dictionary = new Dictionary();
		public static var soundsOn:Boolean = false;
		public static var soundChannel:SoundChannel;
		
		public static function playBackground():void
		{			
			if(sounds["evening"] == null) loadMusicForGame(""); //load sounds if they are turned on
			soundChannel = new SoundChannel();
			soundChannel.addEventListener(Event.SOUND_COMPLETE, replay); 
			replay();
		}
		
		private static function replay(eve:Event = null):void
		{
			soundChannel = sounds["evening"].play(90, 999999);			
		}
		
		public static function stopBackground():void
		{
			if (soundChannel != null) soundChannel.stop();
		}
		
		public static function tryLoadSounds(gameName:String):void
		{
			if (gameName == Misc.SNAKE_GAME && sounds["boost2x"] == null) loadSoundsForGame(gameName);
			else if (gameName == Misc.STACK_UP_GAME && sounds["yourturn"] == null) loadSoundsForGame(gameName);
			else if (gameName == Misc.WORD_SEEKERS_GAME && sounds["wrong"] == null) loadSoundsForGame(gameName);
		}
		
		public static function loadSoundsForGame(gameName:String):void
		{
            var request:URLRequest;
			if (gameName == Misc.SNAKE_GAME)
			{
				var boost2x:Sound = new Sound();
				request = new URLRequest(SOUND_FOLDER + "boost2x.mp3");
				boost2x.load(request);
				sounds["boost2x"] = boost2x;

				var boost3x:Sound = new Sound();
				request = new URLRequest(SOUND_FOLDER + "boost3x.mp3");
				boost3x.load(request);
				sounds["boost3x"] = boost3x;

				var eaten:Sound = new Sound();
				request = new URLRequest(SOUND_FOLDER + "eaten.mp3");
				eaten.load(request);
				sounds["eaten"] = eaten;

				var eatenitself:Sound = new Sound();
				request = new URLRequest(SOUND_FOLDER + "eatenitself.mp3");
				eatenitself.load(request);
				sounds["eatenitself"] = eatenitself;

				var explosion:Sound = new Sound();
				request = new URLRequest(SOUND_FOLDER + "explosion.mp3");
				explosion.load(request);
				sounds["explosion"] = explosion;

				var yo:Sound = new Sound();
				request = new URLRequest(SOUND_FOLDER + "yo.mp3");
				yo.load(request);
				sounds["yo"] = yo;
			}
			else if (gameName == Misc.WORD_SEEKERS_GAME)
			{
				var wrong:Sound = new Sound();
				request = new URLRequest(SOUND_FOLDER + "wrong.mp3");
				wrong.load(request);
				sounds["wrong"] = wrong;
			}
			else if (gameName == Misc.STACK_UP_GAME)
			{
				var yourturn:Sound = new Sound();
				request = new URLRequest(SOUND_FOLDER + "yourturn.mp3");
				yourturn.load(request);
				sounds["yourturn"] = yourturn;
			}
		}		
		
		public static function loadMusicForGame(gameName:String):void
		{
			if (gameName == "snake")
			{

			}
			else if (gameName == "wordSeekers")
			{

			}
			else if (gameName == "stackUp")
			{
				var evening:Sound = new Sound();
				var request:URLRequest = new URLRequest(MUSIC_FOLDER + "evening.mp3");
				evening.load(request);
				sounds["evening"] = evening;
			}
		}				
	}
}