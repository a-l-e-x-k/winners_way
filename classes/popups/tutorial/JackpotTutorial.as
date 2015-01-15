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
	public final class JackpotTutorial extends MovieClipContainer
	{
		private var message:String = Lingvo.dictionary.jptut();
		private var textTimer:Timer = new Timer(33, message.length);
		
		public function JackpotTutorial(xx:Number, yy:Number) 
		{
			super(new jackpotPop(), xx, yy);
			
			textTimer.addEventListener(TimerEvent.TIMER, typeLetter);
			textTimer.addEventListener(TimerEvent.TIMER_COMPLETE, showOk);
			textTimer.start();
			
			Tweener.addTween(_mc.bg_mc, { alpha:0.8, time:1, transition:"easeOutExpo" } );
			
			Networking.trySend("oJP");
			UserData.openedSpiral = true;
		}
		
		private function showOk(e:TimerEvent):void 
		{
			Tweener.addTween(_mc.ok_btn, { alpha:1, time:1, transition:"easeOutExpo" } );		
			_mc.ok_btn.text_txt.text = Lingvo.dictionary["ok"];
			_mc.ok_btn.addEventListener(MouseEvent.ROLL_OVER, onOver);
			_mc.ok_btn.addEventListener(MouseEvent.ROLL_OUT, onOut);
			_mc.ok_btn.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			_mc.ok_btn.addEventListener(MouseEvent.CLICK, dispatchRemove);
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
		
		private function dispatchRemove(e:MouseEvent):void 
		{
			dispatchEvent(new RequestEvent(RequestEvent.REMOVE_ME));
		}
		
		private function typeLetter(e:TimerEvent):void 
		{
			_mc.message_txt.text += message.charAt(textTimer.currentCount - 1);			
		}		
	}
}