package games.stackUp 
{
	import flash.utils.getDefinitionByName;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class World extends MovieClipContainer
	{		
		public function World(worldType:int) 
		{
			var assetClass:Class;
			if (worldType == 0) //sea
			{
				assetClass = getDefinitionByName("sea") as Class;
			}
			else if (worldType == 1) //beach
			{
				assetClass = getDefinitionByName("beach") as Class;
			}
			else if (worldType == 2) //new year
			{
				assetClass = getDefinitionByName("ny") as Class;
			}
			super(new assetClass(), Misc.GAME_AREA_X, Misc.GAME_AREA_Y, true);			
		}		
	}
}