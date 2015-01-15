package popups.tutorial 
{
    import com.gskinner.motion.GTween;
    import com.gskinner.motion.easing.Sine;
    import com.gskinner.motion.plugins.MotionBlurPlugin;

    import events.RequestEvent;

    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    import flash.utils.getDefinitionByName;

    import caurina.transitions.Tweener;

    /**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class SnakeTurorial extends Sprite
	{		
		private var _mc:MovieClip;
		private var _state:String = "basic";

		public function SnakeTurorial() 
		{
			RSLLoader.eventDispatcher.addEventListener(RequestEvent.LOADED_SNAKE_TUTORIAL, startShow);
			RSLLoader.tryLoad("snakeTutorial");
			
			_mc = new MovieClip();			
			addChild(_mc);
		}
		
		private function startShow(e:RequestEvent):void 
		{		
			var assetClass:Class;
			
			assetClass = getDefinitionByName("eatfru") as Class;
			var eatfruits:MovieClip = new assetClass();
			eatfruits.x = Misc.GAME_AREA_WIDTH / 2 - eatfruits.width / 2 - Misc.GAME_AREA_WIDTH;
			eatfruits.y = Misc.GAME_AREA_HEIGHT / 2 - eatfruits.height / 2;
			eatfruits.text_txt.htmlText = Lingvo.dictionary.sn1();
			_mc.addChild(eatfruits);
			
			assetClass = getDefinitionByName("dont") as Class;
			var donteatyourself:MovieClip = new assetClass();
			donteatyourself.x = Misc.GAME_AREA_WIDTH / 2 - donteatyourself.width / 2 - Misc.GAME_AREA_WIDTH * 2;
			donteatyourself.y = Misc.GAME_AREA_HEIGHT / 2 - donteatyourself.height / 2;
			donteatyourself.text_txt.htmlText = Lingvo.dictionary.sn2();
			_mc.addChild(donteatyourself);
			
			assetClass = getDefinitionByName("biggest") as Class;
			var biggestwins:MovieClip = new assetClass();
			biggestwins.x = Misc.GAME_AREA_WIDTH / 2 - biggestwins.width / 2 - Misc.GAME_AREA_WIDTH * 3;
			biggestwins.y = Misc.GAME_AREA_HEIGHT / 2 - biggestwins.height / 2;
			biggestwins.text_txt.htmlText = Lingvo.dictionary.sn3();
			_mc.addChild(biggestwins);
			
			var moveTimer:Timer = new Timer(3000, 4);
			moveTimer.addEventListener(TimerEvent.TIMER, moveWithMotionBlur);
			moveTimer.addEventListener(TimerEvent.TIMER_COMPLETE, prepareForPowerupsTutorial);
			moveTimer.start();
			
			MotionBlurPlugin.install();	
			MotionBlurPlugin.enabled = true;							
			MotionBlurPlugin.strength = 2;
			
			Networking.trySend("oSN");
			UserData.openedSnake = true;
		}
		
		private function moveWithMotionBlur(e:TimerEvent):void 
		{
			new GTween(_mc, 0.5, { x:_mc.x + Misc.GAME_AREA_WIDTH }, { ease:Sine.easeOut, autoPlay:true } );
		}		
		
		private function prepareForPowerupsTutorial(e:TimerEvent):void
		{
			Misc.delayCallback(showPowerupsTutorial, 4000);			
		}
		
		private function showPowerupsTutorial():void
		{
			_mc.x = 0;
			
			if (_mc != null) removeChild(_mc);
			var assetClass:Class = getDefinitionByName("powerPop") as Class;
			_mc = new assetClass();
			_mc.message_txt.text = Lingvo.dictionary.powerTut1();
			addChild(_mc);
			
			Tweener.addTween(_mc.bg_mc, { alpha:0.65, time:1, transition:"easeOutExpo" } );			
			_state = "firstPowerupShown";
		}
		
		public function prepareForSecondPowerupTutorial():void //is called when user uses 1st powerup
		{
			if (_state == "firstPowerupShown") //means 1st powerup tutorial was created already
			{
				removeChild(_mc);
				Misc.delayCallback(showSecondPowerupsTutorial, 11000);
				_state = "";
			}
		}
		
		private function showSecondPowerupsTutorial():void
		{
			var assetClass:Class = getDefinitionByName("powerPop2") as Class;
			_mc = new assetClass();
			_mc.message_txt.text = Lingvo.dictionary.powerTut2();
			addChild(_mc);
			
			Tweener.addTween(_mc.bg_mc, { alpha:0.65, time:1, transition:"easeOutExpo" } );			
			_state = "secondPowerupShown";
		}
		
		public function removeEverything():void
		{
			if (_state == "secondPowerupShown")
			{
				_mc.visible = false;
				_state = "";
			}
		}
	}
}