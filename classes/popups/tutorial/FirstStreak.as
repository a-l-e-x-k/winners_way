package popups.tutorial 
{
    import events.RequestEvent;

    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.utils.Timer;

    import caurina.transitions.Tweener;

    /**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class FirstStreak extends MovieClipContainer
	{
		private var message:String = Lingvo.dictionary.firstStreak();
		private var textTimer:Timer = new Timer(33, message.length);
		
		public function FirstStreak(xx:Number, yy:Number) 
		{
			super(new streak(), xx, yy);
			
			textTimer.addEventListener(TimerEvent.TIMER, typeLetter);
			textTimer.addEventListener(TimerEvent.TIMER_COMPLETE, showBtn);
			textTimer.start();
			
			Tweener.addTween(_mc.bg_mc, { alpha:0.7, time:1, transition:"easeOutExpo" } );
		}
		
		private function showBtn(e:TimerEvent):void 
		{
			_mc.gotcha_btn.text_txt.text = Lingvo.dictionary.gotcha();
			_mc.gotcha_btn.addEventListener(MouseEvent.ROLL_OVER, onOver);
			_mc.gotcha_btn.addEventListener(MouseEvent.ROLL_OUT, onOut);
			_mc.gotcha_btn.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			Tweener.addTween(_mc.gotcha_btn, { alpha:1, time:0.7, transition:"easeOutExpo" } );
			_mc.gotcha_btn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
                dispatchEvent(new RequestEvent(RequestEvent.REMOVE_ME)); } );
		}
		
		private function typeLetter(e:TimerEvent):void
		{
			_mc.message_txt.text += message.charAt(textTimer.currentCount - 1);
		}		
		
		private static function onDown(e:MouseEvent):void
		{
			e.currentTarget.gotoAndStop("down");
		}
		
		private static function onOut(e:MouseEvent):void
		{
			e.currentTarget.gotoAndStop("up");
		}
		
		private static function onOver(e:MouseEvent):void
		{
			e.currentTarget.gotoAndPlay("over");
		}
	}
}