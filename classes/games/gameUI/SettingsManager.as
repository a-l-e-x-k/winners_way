package games.gameUI 
{
    import flash.display.MovieClip;
    import flash.events.MouseEvent;
    import flash.net.SharedObject;

    import caurina.transitions.Tweener;

    /**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class SettingsManager extends MovieClipContainer
	{
		private const SOUNDS_TARGET_Y:int = -37;
		private const MUSIC_TARGET_Y:int = -75;
		private const QUALITY_TARGET_Y:int = -113;
		private var _sharedObject:SharedObject;
		private var _gameName:String;
		
		public function SettingsManager(gameName:String) 
		{
			super(new settings(), 734, 588);
			_gameName = gameName;
			
			_mc.sounds_mc.addEventListener(MouseEvent.CLICK, toggleSounds);
			_mc.music_mc.addEventListener(MouseEvent.CLICK, toggleMusic);
			_mc.quality_mc.addEventListener(MouseEvent.CLICK, toggleQuality);
			
			_mc.sounds_mc.buttonMode = true;
			_mc.music_mc.buttonMode = true;
			_mc.quality_mc.buttonMode = true;
			
			_mc.sounds_mc.y = _mc.music_mc.y= _mc.quality_mc.y = 0;
			_mc.sounds_mc.alpha = _mc.music_mc.alpha = _mc.quality_mc.alpha = 0;			
			
			_sharedObject = SharedObject.getLocal(Misc.SHARED_OBJECT_NAME);
			if (!_sharedObject.data.hasOwnProperty("music")) 
			{
				_sharedObject.data.music = false;
				_sharedObject.data.sounds = false;
				_sharedObject.data.quality = "HIGH";
				toggleMusic(); //turned off by default
				toggleSounds(); //turned off by default
			}
			else //by default everything is turned on
			{ 
				if (!_sharedObject.data.music) toggleMusic(); //if music is turned off
				if (!_sharedObject.data.sounds) toggleSounds(); //if sounds are turned off
				if (_sharedObject.data.quality != "HIGH") toggleQuality(); //if bad quality is selected
			}
			
			_mc.setting_mc.addEventListener(MouseEvent.MOUSE_OVER, showButtons);
			_mc.addEventListener(MouseEvent.ROLL_OUT, hideButtons);
			
			if (SharedObject.getLocal(Misc.SHARED_OBJECT_NAME).data.music) SoundManager.playBackground(); //it;s looping 1 song for now.
		}
		
		private function hideButtons(e:MouseEvent):void 
		{
			Tweener.addTween(_mc.sounds_mc, { y:0, time:0.5, transition:"easeOutExpo" } ); 
			Tweener.addTween(_mc.music_mc, { y:0, time:0.5, transition:"easeOutExpo" } );
			Tweener.addTween(_mc.quality_mc, { y:0, time:0.5, transition:"easeOutExpo" } );
			
			Tweener.addTween(_mc.sounds_mc, { alpha:0, time:0.5, transition:"easeOutExpo" } );
			Tweener.addTween(_mc.music_mc, { alpha:0, time:0.5, transition:"easeOutExpo" } );
			Tweener.addTween(_mc.quality_mc, { alpha:0, time:0.5, transition:"easeOutExpo"} );
		}
		
		private function showButtons(e:MouseEvent):void 
		{
			Tweener.addTween(_mc.sounds_mc, { y:SOUNDS_TARGET_Y, time:0.5, transition:"easeOutExpo" } );
			Tweener.addTween(_mc.music_mc, { y:MUSIC_TARGET_Y, time:0.5, transition:"easeOutExpo" } );
			Tweener.addTween(_mc.quality_mc, { y:QUALITY_TARGET_Y, time:0.5, transition:"easeOutExpo" } );
			
			Tweener.addTween(_mc.sounds_mc as MovieClip, { alpha:1, time:0.5, transition:"easeOutExpo" } );
			Tweener.addTween(_mc.music_mc as MovieClip, { alpha:1, time:0.5, transition:"easeOutExpo" } );
			Tweener.addTween(_mc.quality_mc as MovieClip, { alpha:1, time:0.5, transition:"easeOutExpo"} );
		}
		
		private function toggleSounds(e:MouseEvent = null):void 
		{
			_mc.sounds_mc.gotoAndStop(_mc.sounds_mc.currentFrame == 2?1:2);
			if (e != null) _sharedObject.data.sounds = !_sharedObject.data.sounds;
			SoundManager.soundsOn = _sharedObject.data.sounds;
			if (_sharedObject.data.sounds) SoundManager.tryLoadSounds(_gameName);
			_sharedObject.flush();
		}
		
		private function toggleMusic(e:MouseEvent = null):void 
		{
			_mc.music_mc.gotoAndStop(_mc.music_mc.currentFrame == 2?1:2);
			if (e != null) _sharedObject.data.music = !_sharedObject.data.music; //if user changed music -> change music property in shared object
			if (!_sharedObject.data.music) SoundManager.stopBackground();
			else SoundManager.playBackground();
			_sharedObject.flush();
		}
		
		private function toggleQuality(e:MouseEvent = null):void 
		{			
			if (e != null) 
			{ 
				Networking.client.stage.quality = Networking.client.stage.quality == "HIGH"? "MEDIUM":"HIGH";			
				_sharedObject.data.quality = Networking.client.stage.quality;
			}
			else Networking.client.stage.quality = _sharedObject.data.quality;
			_mc.quality_mc.gotoAndStop(Networking.client.stage.quality == "HIGH" ? 1 : 2);
		}
		
	}

}