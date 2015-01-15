package games.snake.field 
{
	import flash.display.Sprite;
	import flash.utils.getDefinitionByName;
	import games.snake.SnakeData;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class FieldGrid extends Sprite
	{
		
		public function FieldGrid() 
		{
			this.x = -1; //because of blur effect
			this.y = -1; //because of blur effect
			for (var i:int = 0; i < SnakeData.FIELD_WIDTH; i++) //grid
			{
				for (var j:int = 0; j < SnakeData.FIELD_HEIGHT; j++)
				{					
					var assetClass:Class =  getDefinitionByName("cellborders") as Class;				
					
					var cell:Sprite = new assetClass();
					cell.x = SnakeData.PART_SIZE * i;
					cell.y = SnakeData.PART_SIZE * j;
					addChild(cell);
				}
			}
			
			this.cacheAsBitmap = true;
		}
		
	}

}