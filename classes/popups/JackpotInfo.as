package popups 
{
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class JackpotInfo extends Popup 
	{		
		public function JackpotInfo() 
		{
			super(new jackpotInfo(), 386, 330, true);
			_mc.label_txt.text = Lingvo.dictionary.jackpot();
			_mc.desription_txt.text = Lingvo.dictionary.descriptionJp();
			_mc.towin_txt.text = Lingvo.dictionary.toWinjp();
		}		
	}
}