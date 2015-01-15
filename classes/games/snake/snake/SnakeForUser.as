package games.snake.snake 
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.utils.getDefinitionByName;
	import games.snake.SnakeData;
	import playerio.Connection;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class SnakeForUser extends Snake
	{
		private var _turnRequested:Object = {}; //used for user's snake only
		private var _connection:Connection;
		
		public function SnakeForUser(situationID:int, color:int, connection:Connection) 
		{
			super(situationID, color);
			_connection = connection;
			_tokens = 4 * 8 + 8; //tokens 4 4 cells (8 3px moves), + 8 as a buffer
			
			var assetClass:Class = getDefinitionByName("pregame") as Class;
			var pregameAnim:MovieClip = new assetClass();
			pregameAnim.x = head.x + SnakeData.PART_SIZE / 2;
			pregameAnim.y = head.y + SnakeData.PART_SIZE / 2;
			pregameAnim.addEventListener(Event.ENTER_FRAME, function(e:Event):void {
				if (pregameAnim.totalFrames == pregameAnim.currentFrame && contains(pregameAnim)) removeChild(pregameAnim); 
				else
					{
						pregameAnim.x = head.x + SnakeData.PART_SIZE / 2;
						pregameAnim.y = head.y + SnakeData.PART_SIZE / 2;
					}
				} ); 
			addChild(pregameAnim);
		}
		
		public function turnTo(dir:String):void
		{
			if (!((_direction == "right" && dir == "left") || (_direction == "left" && dir == "right") || (_direction == "up" && dir == "down") || (_direction == "down" && dir == "up") || (_direction == dir)))
			{
				_turnRequested = { direction:dir, index:0 };
			}
		}
		
		override protected function checkForTurn(startedSevenMinesPlacement:Boolean = false):void
		{
			if (_turnRequested.direction != null)
			{
				var marginalBefore:Boolean = _parts[_parts.length - 2].futureTurns.length > 0 && _parts[_parts.length - 2].futureTurns[_parts[_parts.length - 2].futureTurns.length - 1].marginal;	
				var doubleTurn:Boolean = (_parts[_parts.length - 2].turnCounter >= (SnakeData.PART_SIZE / head.STEP_SIZE) - 1);		
				var oneCellBack:Object = SnakeData.backwardCell(head.i, head.j, _direction);
				var marginal:Boolean = (_direction == "left" && head.i >= (SnakeData.FIELD_WIDTH - 1)) || (_direction == "right" && head.i <= 0) || (_direction == "up" && head.j >= (SnakeData.FIELD_HEIGHT - 1)) || (_direction == "down" && head.j <= 0);
				
				if (!(doubleTurn && marginal) && !marginalBefore)
				{									
					for each (var part:SnakePart in _parts) 					
					{
						if (part.type != "head") 
						{
							part.addTurn(oneCellBack.i, oneCellBack.j, _turnRequested.direction, doubleTurn, marginal?_direction:"");					
							part.trytryTurn(marginal, _parts.indexOf(part) == _parts.length - 2);
						}
						part.realFutureTurns.push( { i:head.realI, j:head.realJ, direction:_turnRequested.direction } );
						part.tryRealTurn();
					}					
					
					head.addTurn(head.i, head.j, _turnRequested.direction, false, marginal?_direction:"");	
					sendTurn(startedSevenMinesPlacement);					
					head.trytryTurn(marginal, _parts.indexOf(part) == _parts.length - 2);					
					_direction = _turnRequested.direction;
					_turnRequested = {};
					_turnPushPossible = false;		
				}			
				else sendForward(startedSevenMinesPlacement);				
			}
			else sendForward(startedSevenMinesPlacement);
		}
		
		private function sendForward(startedSevenMinesPlacement:Boolean):void
		{
			if (startedSevenMinesPlacement) _connection.send("0", true);
			else _connection.send("0");
		}
		
		private function sendTurn(startedSevenMinesPlacement:Boolean):void
		{ //server should receive calculated at SnakePart i&j (which depend on marginalTurn - coordinates are changed theres)		
			if (startedSevenMinesPlacement)
            {
                _connection.send("0", head.futureTurns[head.futureTurns.length - 1].i, head.futureTurns[head.futureTurns.length - 1].j, SnakeData.getDirectionCode(_turnRequested.direction), true);
            }
			else
            {
                _connection.send("0", head.futureTurns[head.futureTurns.length - 1].i, head.futureTurns[head.futureTurns.length - 1].j, SnakeData.getDirectionCode(_turnRequested.direction));
            }
		}
	}
}