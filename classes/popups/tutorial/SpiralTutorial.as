package popups.tutorial 
{
    import flash.events.TimerEvent;
    import flash.utils.Timer;

    import caurina.transitions.Tweener;

    /**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class SpiralTutorial extends MovieClipContainer
	{
		private var message:String = Lingvo.dictionary.spiraltut();
		private var textTimer:Timer = new Timer(33, message.length);
		
		public function SpiralTutorial(xx:Number, yy:Number) 
		{
			super(new spiralPop(), xx, yy);
			
			textTimer.addEventListener(TimerEvent.TIMER, typeLetter);
			textTimer.start();
			
			Tweener.addTween(_mc.bg_mc, { alpha:0.8, time:1, transition:"easeOutExpo" } );
			
			Networking.trySend("oSP");
			UserData.openedSpiral = true;
		}
		
		private function typeLetter(e:TimerEvent):void
		{
			_mc.message_txt.text += message.charAt(textTimer.currentCount - 1);			
		}		
	}
}