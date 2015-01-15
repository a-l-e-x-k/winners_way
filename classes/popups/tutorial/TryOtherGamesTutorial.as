package popups.tutorial 
{
    import flash.events.TimerEvent;
    import flash.utils.Timer;

    import caurina.transitions.Tweener;

    /**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class TryOtherGamesTutorial extends MovieClipContainer
	{
		private var message:String = Lingvo.dictionary.tryOtherGames();
		private var textTimer:Timer = new Timer(33, message.length);
		
		public function TryOtherGamesTutorial() 
		{
			super(new tryother(), 0, 0);
			
			textTimer.addEventListener(TimerEvent.TIMER, typeLetter);
			textTimer.start();
			
			Tweener.addTween(_mc.bg_mc, { alpha:0.8, time:1, transition:"easeOutExpo" } );
			
			UserData.triedOtherGames = true;
		}
		
		private function typeLetter(e:TimerEvent):void 
		{
			_mc.message_txt.text += message.charAt(textTimer.currentCount - 1);			
		}		
	}
}