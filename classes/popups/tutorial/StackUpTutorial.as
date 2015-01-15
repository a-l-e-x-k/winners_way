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
	public final class StackUpTutorial extends Sprite
	{
		private var message:String = Lingvo.dictionary.sutut();
		private var textTimer:Timer = new Timer(33, message.length);
		private var moveTimer:Timer;
		public var state:String = "basic";
		private var _mc:MovieClip;
		
		public function StackUpTutorial() 
		{
			RSLLoader.eventDispatcher.addEventListener(RequestEvent.LOADED_STACK_UP_TUTORIAL, go);
			RSLLoader.tryLoad("stackUpTutorial");			
		}
		
		private function go(e:RequestEvent):void 
		{
			RSLLoader.eventDispatcher.removeEventListener(RequestEvent.LOADED_STACK_UP_TUTORIAL, go);
			
			var assetClass:Class = getDefinitionByName("stackUpTut") as Class;
			_mc = new assetClass();
			addChild(_mc);
			
			_mc.bg_mc.alpha = 0;
			
			textTimer.addEventListener(TimerEvent.TIMER, typeLetter);
			textTimer.start();
			
			Tweener.addTween(_mc.bg_mc, { alpha:0.8, time:1, transition:"easeOutExpo" } );
		}
		
		public function hide():void
		{
			if (_mc != null) _mc.visible = false; //if-check for dev only (just fires bug)
			state = "tutorialShown";
		}
		
		public function showFirstTips():void
		{
			var assetClass:Class;
			
			assetClass = getDefinitionByName("ontop") as Class;
			var stackOnTop:MovieClip = new assetClass();
			stackOnTop.x = Misc.GAME_AREA_WIDTH / 2 - stackOnTop.width / 2 - Misc.GAME_AREA_WIDTH;
			stackOnTop.y = Misc.GAME_AREA_HEIGHT / 2 - stackOnTop.height / 2;
			stackOnTop.text_txt.htmlText = Lingvo.dictionary.st1();
			addChild(stackOnTop);
			
			assetClass = getDefinitionByName("dontfall") as Class;
			var dontFall:MovieClip = new assetClass();
			dontFall.x = Misc.GAME_AREA_WIDTH / 2 - dontFall.width / 2 - Misc.GAME_AREA_WIDTH * 2;
			dontFall.y = Misc.GAME_AREA_HEIGHT / 2 - dontFall.height / 2;
			dontFall.text_txt.htmlText = Lingvo.dictionary.st2();
			addChild(dontFall);
			
			assetClass = getDefinitionByName("noreel") as Class;
			var noReeling:MovieClip = new assetClass();
			noReeling.x = Misc.GAME_AREA_WIDTH / 2 - noReeling.width / 2 - Misc.GAME_AREA_WIDTH * 3;
			noReeling.y = Misc.GAME_AREA_HEIGHT / 2 - noReeling.height / 2;
			noReeling.text_txt.htmlText = Lingvo.dictionary.st3();
			addChild(noReeling);
			
			assetClass = getDefinitionByName("usepower") as Class;
			var usePowerups:MovieClip = new assetClass();
			usePowerups.x = Misc.GAME_AREA_WIDTH / 2 - usePowerups.width / 2 - Misc.GAME_AREA_WIDTH * 4;
			usePowerups.y = Misc.GAME_AREA_HEIGHT / 2 - usePowerups.height / 2;
			usePowerups.text_txt.htmlText = Lingvo.dictionary.st4();
			addChild(usePowerups);					
			
			MotionBlurPlugin.install();	
			MotionBlurPlugin.enabled = true;							
			MotionBlurPlugin.strength = 2;
			
			moveTimer = new Timer(3000, 1);
			moveTimer.addEventListener(TimerEvent.TIMER, moveWithMotionBlur);
			moveTimer.addEventListener(TimerEvent.TIMER_COMPLETE, hideTips);
			moveTimer.start();

            UserData.openedStackUp = true;
			
			moveWithMotionBlur();
		}
		
		public function showSecondTips():void
		{
			new GTween(this, 0.3, { alpha:1 }, { ease:Sine.easeOut, autoPlay:true } );
			moveTimer = new Timer(4000, 2);
			moveTimer.addEventListener(TimerEvent.TIMER, moveWithMotionBlur);
			moveTimer.start();
			moveWithMotionBlur();
		}
		
		private function moveWithMotionBlur(e:TimerEvent = null):void 
		{
			new GTween(this, 0.3, { x:this.x + Misc.GAME_AREA_WIDTH }, { ease:Sine.easeOut, autoPlay:true } );
		}		
		
		private function hideTips(e:TimerEvent):void 
		{
			moveTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, hideTips);
			var thiss:Sprite = this;
			Misc.delayCallback(function():void { new GTween(thiss, 0.3, { alpha:0 }, { ease:Sine.easeOut, autoPlay:true } ); }, 3000);
			state = "firstTipsShown";
		}
		
		private function typeLetter(e:TimerEvent):void
		{
			_mc.message_txt.text += message.charAt(textTimer.currentCount - 1);			
		}		
	}
}