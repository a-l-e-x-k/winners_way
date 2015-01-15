package games.snake.field 
{
	import flash.utils.getDefinitionByName;
	import games.snake.SnakeData;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class Mine extends MovieClipContainer
	{
		private var _j:int;
		private var _i:int;
		private var _creator:String;
		public function Mine(color:uint, i:int, j:int, creator:String) 
		{
			trace("Mine created");
			_creator = creator;
			_i = i;
			_j = j;
			var assetClass:Class =  getDefinitionByName("mineItem") as Class;		
			super(new assetClass(), i * SnakeData.PART_SIZE + SnakeData.PART_SIZE / 2, j * SnakeData.PART_SIZE + SnakeData.PART_SIZE / 2);	
			Misc.applyColorTransform(_mc.color_mc, Misc.POSSIBLE_COLORS[color]); //u can't hit your own mine. It's safe 4 u 
		}
		
		public function get j():int 
		{
			return _j;
		}
		
		public function get i():int 
		{
			return _i;
		}
		
		public function get creator():String 
		{
			return _creator;
		}
		
	}

}