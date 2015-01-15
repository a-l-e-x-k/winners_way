package lobby.spiral 
{
	import events.RequestEvent;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class SpiralButton extends MovieClipContainer
	{		
		public function SpiralButton() 
		{
			super(new myspiralbtn(), 626, 4.8);
			if (UserData.winCount != -1 && UserData.winCount < Misc.WINS_TO_UNLOCK_SPIRAL) 
			{
				_mc.tounlock_txt.text = Lingvo.dictionary.getWinMore(Misc.WINS_TO_UNLOCK_SPIRAL - UserData.winCount); //if have not gathered enough wins to open spiral
			}
			else
			{
				_mc.gotoAndStop(2);
				_mc.logo_mc.text_txt.text = Lingvo.dictionary.myspiral();
				_mc.addEventListener(MouseEvent.CLICK, dispatchShowSpiral);
				this.buttonMode = true;
			}			
		}
		
		private function dispatchShowSpiral(e:MouseEvent):void 
		{
			dispatchEvent(new RequestEvent(RequestEvent.IMREADY));
		}
	}
}