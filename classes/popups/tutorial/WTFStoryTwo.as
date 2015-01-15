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
	public final class WTFStoryTwo extends MovieClipContainer
	{
		private var message:String = Lingvo.dictionary.wtfstory2_1();
		private var textTimer:Timer = new Timer(33, message.length);
		
		public function WTFStoryTwo() 
		{
			super(new wtfstory2(), 0, 0);			
			Tweener.addTween(_mc.part1_mc, { alpha:1, time:1.3, delay:0.7, transition:"easeOutExpo", onComplete:startTyping } );			
		}
		
		private function startTyping():void
		{
			trace("startTyping");
			trace("message: " + message);
			textTimer.addEventListener(TimerEvent.TIMER, typeFirstMessage);
			textTimer.addEventListener(TimerEvent.TIMER_COMPLETE, showPartTwo);
			textTimer.start();
		}
		
		private function typeFirstMessage(e:TimerEvent):void
		{
			_mc.part1_mc.message_txt.text += message.charAt(textTimer.currentCount - 1);			
		}	
		
		private function showPartTwo(e:TimerEvent):void 
		{
			Tweener.addTween(_mc.part1_mc, { alpha:0, time:0.5, delay:2, transition:"easeOutExpo" } );			
			Tweener.addTween(_mc.part2_mc, { alpha:1, time:1.5, delay:2.5, transition:"easeOutExpo", onComplete:startSecondTyping } );				
		}	
		
		private function startSecondTyping():void 
		{
			Misc.delayCallback(function():void
			{
				message = Lingvo.dictionary.wtfstory2_2_1();
				textTimer = new Timer(33, message.length);
				textTimer.addEventListener(TimerEvent.TIMER, typeSecondMessage);
				textTimer.addEventListener(TimerEvent.TIMER_COMPLETE, startThirdTyping);
				textTimer.start();
			}, 500);
		}	
		
		private function typeSecondMessage(e:TimerEvent):void 
		{
			_mc.part2_mc.message1_txt.text += message.charAt(textTimer.currentCount - 1);			
		}
		
		private function startThirdTyping(e:TimerEvent):void 
		{
			Misc.delayCallback(function():void
			{
				message = Lingvo.dictionary.wtfstory2_2_2();
				textTimer = new Timer(33, message.length);
				textTimer.addEventListener(TimerEvent.TIMER, typeThirdMessage);
				textTimer.addEventListener(TimerEvent.TIMER_COMPLETE, showCoolBtn);
				textTimer.start();
			}, 1250);
		}		
		
		private function typeThirdMessage(e:TimerEvent):void 
		{
			_mc.part2_mc.message2_txt.text += message.charAt(textTimer.currentCount - 1);	
		}
		
		private function showCoolBtn(e:TimerEvent):void 
		{
			Tweener.addTween(_mc.part2_mc.cool_btn, { alpha:1, time:1, delay:0.5, transition:"easeOutExpo" } );	
			_mc.part2_mc.cool_btn.text_txt.text = Lingvo.dictionary.cool();
			_mc.part2_mc.cool_btn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void { dispatchEvent(new RequestEvent(RequestEvent.IMREADY)); } );
			_mc.part2_mc.cool_btn.addEventListener(MouseEvent.ROLL_OVER, onOver);
			_mc.part2_mc.cool_btn.addEventListener(MouseEvent.ROLL_OUT, onOut);
			_mc.part2_mc.cool_btn.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
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