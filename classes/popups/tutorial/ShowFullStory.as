package popups.tutorial 
{
    import flash.events.TimerEvent;
    import flash.utils.Timer;

    import caurina.transitions.Tweener;

    /**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class ShowFullStory extends MovieClipContainer
	{
		private var message:String = Lingvo.dictionary.gofull();
		private var textTimer:Timer = new Timer(33, message.length);
		
		public function ShowFullStory(xx:Number, yy:Number) 
		{
			super(new fullStoryPop(), xx, yy);		
			
			textTimer.addEventListener(TimerEvent.TIMER, typeLetter);
			textTimer.start();			
			Tweener.addTween(_mc.bg_mc, { alpha:0.7, time:1, transition:"easeOutExpo" } );
		}
		
		private function typeLetter(e:TimerEvent):void
		{
			_mc.message_txt.text += message.charAt(textTimer.currentCount - 1);			
		}		
	}
}