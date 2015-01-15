package lobby.shop.sections.shelves.packsShelf 
{
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class PackLogo extends MovieClipContainer
	{		
		public function PackLogo() 
		{
			super(new offerlogo(), -385, 103);		
			if (Lingvo.dictionary.LANGUAGE == "RUS") _mc.gotoAndStop(2);
		}		
	}
}