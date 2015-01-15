package lobby.shop.sections.shelves.packsShelf 
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class PacksShelf extends Sprite
	{		
		public function PacksShelf() 
		{
			var mcs:Array = [new fifty(), new hundred(), new twoFifty()];
			
			for (var i:int = 0; i < 3; i++)
			{
				var offer:Pack = new Pack(mcs[i], i, PowerupsManager.getPackInfo(i));
				addChild(offer);
			}
		}	
	}
}