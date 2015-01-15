package games.snake.field 
{
	import flash.display.Sprite;
	import flash.utils.getDefinitionByName;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class TopField extends Sprite
	{
		public var missileLauncher:MissileLauncher = new MissileLauncher();
		
		public function TopField(fieldType:String) 
		{	
			var assetClass:Class;
			if (fieldType == "desert")
			{
				assetClass = getDefinitionByName("agava") as Class;
				var aga:Sprite = new assetClass();
				aga.x = 100;
				aga.y = 130;
				addChild(aga);
			}
			else if (fieldType == "glade")
			{
				assetClass = getDefinitionByName("strawberry") as Class;
				var str:Sprite = new assetClass();
				str.x = 430;
				str.y = 53;
				addChild(str);
				
				assetClass = getDefinitionByName("burdock") as Class;
				var bur:Sprite = new assetClass();
				bur.x = -58.6;
				bur.y = -87;
				addChild(bur);								
			}
			else if (fieldType == "forest")
			{
				assetClass = getDefinitionByName("fern") as Class;
				var fern:Sprite = new assetClass();
				fern.x = 575.2;
				fern.y = -118;
				addChild(fern);
				
				assetClass = getDefinitionByName("bilberries") as Class;
				var bilberries:Sprite = new assetClass();
				bilberries.x = -58.6;
				bilberries.y = 466;
				addChild(bilberries);
			}			
			
			addChild(missileLauncher);			
		}		
	}
}