package games.snake 
{
	import games.snake.snake.SnakePart;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class SnakeData 
	{
		public static const PART_SIZE:int = 24;
		public static const FIELD_WIDTH:int = 33;
		public static const FIELD_HEIGHT:int = 26;
		public static const POSITIONS_I:Array = [ 6, 6, 6, 7, 8, 12, 12, 15, 16, 19, 19, 21, 21, 25, 26, 27, 27, 11, 18, 17, 23 ];
		public static const POSITIONS_J:Array = [ 6, 13, 20, 17, 9, 6, 20, 8, 19, 6, 21, 10, 17, 9, 18, 6, 13, 12, 11, 14, 15 ];
		public static const DIRECTIONS:Array = [ 0, 0, 0, 0, 0, 1, 3, 1, 3, 1, 3, 1, 3, 2, 2, 2, 2, 0, 1, 2, 3 ];
		public static const DIRECTIONS_NAMES:Array = ["right", "down", "left", "up"];
		
		public static function forwardCell(fromI:int, fromJ:int, direction:String):Object
		{
			var resultI:int;
			var resultJ:int;
			if (direction == "up")
			{
				resultI = fromI;
				resultJ = fromJ == -1?FIELD_HEIGHT:fromJ - 1;
			}
			else if (direction == "right")
			{
				resultI = fromI == FIELD_WIDTH?-1:fromI + 1;
				resultJ = fromJ;
			}
			else if (direction == "down")
			{
				resultI = fromI;
				resultJ = fromJ == FIELD_HEIGHT?-1:fromJ + 1;
			}
			else if (direction == "left")
			{
				resultI = fromI == -1?FIELD_WIDTH:fromI - 1;
				resultJ = fromJ;
			}
			var result:Object = { i:resultI, j:resultJ };
			return result;			
		}
		
		public static function backwardCell(fromI:int, fromJ:int, direction:String):Object
		{			
			var resultI:int;
			var resultJ:int;
			if (direction == "up")
			{
				resultI = fromI;
				resultJ = fromJ == FIELD_HEIGHT?-1:fromJ + 1;
			}
			else if (direction == "right")
			{
				resultI = fromI == -1?FIELD_WIDTH:fromI - 1;
				resultJ = fromJ;
			}
			else if (direction == "down")
			{
				resultI = fromI;
				resultJ = fromJ == -1?FIELD_HEIGHT:fromJ - 1;
			}
			else if (direction == "left")
			{
				resultI = fromI == FIELD_WIDTH?-1:fromI + 1;				
				resultJ = fromJ;
			}
			var result:Object = { i:resultI, j:resultJ };
			return result;			
		}	
		
		public static function isExactly(head:SnakePart):Boolean		
		{
			return head.turnCounter == -1 && ((head.x % SnakeData.PART_SIZE == 0 && (head.direction == "left" || head.direction == "right")) || (head.y % PART_SIZE == 0 && (head.direction == "up" || head.direction == "down")));
		}
		
		public static function getFieldName(fieldNumber:int):String
		{
			var fieldName:String = "";
			if (fieldNumber == 0) fieldName = "glade"
			else if (fieldNumber == 1) fieldName = "forest"
			else if (fieldNumber == 2) fieldName = "desert"
			return fieldName;
		}
		
		public static function getDirectionCode(direction:String):int 
		{
			var code:int;
			if (direction == "right") code = 0;
			else if (direction == "down") code = 1;
			else if (direction == "left") code = 2;
			else if (direction == "up") code = 3;
			return code;
		}
		
		public static function getDirectionName(direction:int):String 
		{
			var name:String;
			if (direction == 0) name = "right";
			else if (direction == 1) name = "down";
			else if (direction == 2) name = "left";
			else if (direction == 3) name = "up";
			return name;
		}	
		
		public static function checkPowerupTargetCell(previousI:int, previousJ:int, currentI:int, currentJ:int, targetCellObj:Object):Boolean
		{			
			trace("previousI: " + previousI + " previousJ: " + previousJ + " currentI: " + currentI + " currentJ: " + currentJ);
			trace("targ.preI: " + targetCellObj.preTargetCellI + " targ.preJ: " + targetCellObj.preTargetCellJ + " targ.taI: " + targetCellObj.targetCellI + " targ.taJ: " + targetCellObj.targetCellJ);
			trace("--------------------------------------------------------------------");
			var preEquals:Boolean = targetCellObj.preTargetCellI == previousI && targetCellObj.preTargetCellJ == previousJ;
			var currentEquals:Boolean = targetCellObj.targetCellI == currentI && targetCellObj.targetCellJ == currentJ;
			return preEquals && currentEquals;
		}
	}
}