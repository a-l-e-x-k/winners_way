package lobby.shop 
{
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class NotEnough extends MovieClipContainer 
	{		
		public function NotEnough() 
		{
			super(new notEnough(), 387, 313);
			_mc.oops_txt.text = Lingvo.dictionary.notenough();
			_mc.cancel_btn.bg.text_txt.text = Lingvo.dictionary.cancel();
			Misc.addSimpleButtonListeners(_mc.add_btn);
			Misc.addSimpleButtonListeners(_mc.cancel_btn);
			_mc.add_btn.bg.text_txt.text = Lingvo.dictionary.addCoins();
		}		
	}
}