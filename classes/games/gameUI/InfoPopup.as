package games.gameUI 
{
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class InfoPopup extends MovieClipContainer
	{		
		public function InfoPopup(powerupType:String) 
		{
			super(new powerupInfo());
			_mc.text_txt.text = Lingvo.dictionary.getPowerupDescription(powerupType);
		}		
	}
}