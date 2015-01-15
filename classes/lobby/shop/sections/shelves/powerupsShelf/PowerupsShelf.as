package lobby.shop.sections.shelves.powerupsShelf 
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public class PowerupsShelf extends Sprite
	{		
		public function PowerupsShelf() 
		{			
			for (var j:int = 0; j < Misc.GAMES_NAMES.length; j++) 
			{
				var powerupsForGame:Array = PowerupsManager.getPowerupsForGame(Misc.GAMES_NAMES[j]);
				for (var i:int = 0; i < powerupsForGame.length; i++)
				{
					var item:ShopPowerup = new ShopPowerup(powerupsForGame[i], i, j);				
					addChild(item);
				}
			}
		}				
	}
}