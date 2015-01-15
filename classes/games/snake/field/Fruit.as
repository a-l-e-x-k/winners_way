package games.snake.field 
{
	import flash.utils.getDefinitionByName;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class Fruit extends MovieClipContainer
	{
		private var _i:int;
		private var _j:int;
		
		public function Fruit(x:int, y:int, fruitType:int, i:int, j:int)
		{
			_j = j;
			_i = i;

            var assetClass:Class;
            switch (fruitType)
            {
                case 0:
                    assetClass = getDefinitionByName("apple") as Class;
                    break;
                case 1:
                    assetClass = getDefinitionByName("orange") as Class;
                    break;
                case 2:
                    assetClass = getDefinitionByName("watermelon") as Class;
                    break;
                case 3:
                    assetClass = getDefinitionByName("lemon") as Class;
                    break;
            }

			super(new assetClass(), x, y);
		}
		
		public function get i():int 
		{
			return _i;
		}
		
		public function get j():int 
		{
			return _j;
		}
		
	}

}