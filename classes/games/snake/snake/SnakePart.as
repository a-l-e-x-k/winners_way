package games.snake.snake 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.utils.getDefinitionByName;
	import games.snake.SnakeData;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class SnakePart extends Sprite
	{
		public const STEP_SIZE:Number = 3;  //3px movements
		private var _direction:String;
		private var _j:int;
		private var _i:int;
		private var _type:String;
		private var _color:int;
		private var _growModeCounter:int = 0;
		private var _turnDirection:String = "";
		private var _turnCounter:int = -1;
		private var _reverseMe:Boolean;
		private var _futureTurns:Array = [];
		private var _doubleTurn:Boolean = false;
		private var _graphics:SnakePartGraphic;
		private var _withHead:Boolean;
		private var _realJ:int; //the same as server. perfect sync
		private var _realI:int; //the same as server. perfect sync
		private var _realDirection:String = ""; //the same as server. perfect sync
		private var _realFutureTurns:Array = []; //the same as server. perfect sync
		
		public function SnakePart(partType:String, directionS:String, color:int)
		{
			_color = color;
			_type = partType;
			createGraphics(partType);
			direction = directionS;
			_realDirection = directionS;
		}
		
		private function createGraphics(graphicsType:String):void
		{			
			var assetClass:Class = getDefinitionByName(graphicsType) as Class;
			_graphics = new SnakePartGraphic(graphicsType, new assetClass() as MovieClip, _color);
			_graphics.x += SnakeData.PART_SIZE / 2;
			_graphics.y += SnakeData.PART_SIZE / 2;
			addChild(_graphics);			
		}
		
		public function setStartPoint(i:Number, j:Number):void
		{
			_i = _realI = i;
			_j = _realJ = j;
			x = i * SnakeData.PART_SIZE;
			y = j * SnakeData.PART_SIZE;
		}
		
		public function addTurn(i:int, j:int, direction:String, doubleTurn:Boolean = false, marginalDirection:String = ""):void
		{//marginalDirection - if turn is off the field (over the borders) -> so it's moved 1 cell forward (so snake will not turn in invisible area)			
			if (marginalDirection == "")
			{
				_futureTurns.push( { i:i, j:j, direction:direction, doubleTurn:doubleTurn } );				
			}
			else if (marginalDirection == "left") //marginal property is used 4 detecting "doubleTurns" for parts[partslength-2] (because they don't insta-start). Fix for chopping snake's head off. When such a thing happens, no turn allowed
			{
				_futureTurns.push( { i:_type == "head"?SnakeData.FIELD_WIDTH - 1:SnakeData.FIELD_WIDTH, j:j, direction:direction, doubleTurn:doubleTurn, marginal:true } );
			}
			else if (marginalDirection == "up")
			{
				_futureTurns.push( { i:i, j:_type == "head"?SnakeData.FIELD_HEIGHT - 1:SnakeData.FIELD_HEIGHT, direction:direction, doubleTurn:doubleTurn, marginal:true } );
			}
			else if (marginalDirection == "right")
			{
				_futureTurns.push( { i:_type == "head"?0:-1, j:j, direction:direction, doubleTurn:doubleTurn, marginal:true } ); 
			}
			else if (marginalDirection == "down")
			{
				_futureTurns.push( { i:i, j:_type == "head"?0:-1, direction:direction, doubleTurn:doubleTurn, marginal:true } );
			}					
		}		
		
		public function trytryTurn(marginal:Boolean, iamfirstbody:Boolean):void
		{
			if (!marginal)
			{
				if (_type == "head") 
				{
					performTurn(); //turn head right away
				}
				else if (iamfirstbody) 
				{
					_withHead = true;
					tryTurn();				
				}
			}
		}
		
		public function move():void 
		{			
			if (_growModeCounter == 0)
			{			
				if (_turnDirection == "")
                {
                    changePosition();
                }
				else
				{
					if (_turnCounter > 0) 
					{
						_graphics.nextFrame(_withHead); //if (_turnCounter % 3 == 0)
						_turnCounter--;
					}
					else 
					{
						if(_reverseMe)
                        {
                            _graphics.scaleX *= -1; //flip mc horizontally;
                        }

                        _graphics.finishTurn();

						if (_type != "head")
                        {
                            for (var i:int = 0; i < SnakeData.PART_SIZE / STEP_SIZE; i++)
                            {
                                changePosition(true); //move 1 cell forward
                            }
                        }

						direction = _turnDirection;

						if (_type != "tail")
                        {
                            for (var j:int = 0; j < SnakeData.PART_SIZE / STEP_SIZE; j++)
                            {
                                changePosition(true); //move 1 cell forward
                            }
                        }
						
						_turnDirection = "";
						_turnCounter = -1;	
						_withHead = false;
					}
				}
			}
			else _growModeCounter--;		
		}
		
		public function changeRealCoordinates():void 
		{			
			if (_growModeCounter == 0)
			{				
				//if (_type == "tail" && this.parent is SnakeForUser) trace("real: " + _realI + " - " + _realJ + " realdirection: " + _realDirection );
				_realI = getNextIJ(_realI, _realJ, _realDirection).i;
				_realJ = getNextIJ(_realI, _realJ, _realDirection).j;
				tryRealTurn();	
			}			
		}
		
		public function tryRealTurn():void
		{
			if (_realFutureTurns.length > 0)
			{
				if (_realI == _realFutureTurns[0].i && _realJ == _realFutureTurns[0].j) 
				{		
					//trace("really turned at: " + _realI + " - " + _realJ + " type: " + _type +  " realdirection: " + _realDirection + " _realFutureTurns.i " + _realFutureTurns[0].i + " _realFutureTurns.j: " + _realFutureTurns[0].j);
					_realDirection = _realFutureTurns[0].direction;
					_realFutureTurns.shift();
				}
			}
		}
		
		private function changePosition(forced:Boolean = false):void 
		{		
			if (_direction == "right") x += STEP_SIZE; 
			else if (_direction == "left") x -= STEP_SIZE;
			else if (_direction == "down") y += STEP_SIZE;
			else if (_direction == "up") y -= STEP_SIZE;
			
			if (((_direction == "right" || _direction == "left") && (x % SnakeData.PART_SIZE == 0 || Math.abs(x) % SnakeData.PART_SIZE ==  SnakeData.PART_SIZE ||  x == 0)) || ((_direction == "down" || _direction == "up") && (y % SnakeData.PART_SIZE == 0 || Math.abs(y) % SnakeData.PART_SIZE ==  SnakeData.PART_SIZE || y == 0)))
			{		
				changeCoordinates(forced);																
			}				
		}
		
		public function changeCoordinates(forced:Boolean = false):void 
		{
			_i = getNextIJ(_i, _j, _direction).i;
			_j = getNextIJ(_i, _j, _direction).j;
			
			if ((_growModeCounter == 0 && _turnDirection == "") || forced) //sync x&y to i*j 
			{
				x = _i * SnakeData.PART_SIZE; //change x & y properties
				y = _j * SnakeData.PART_SIZE; //change x & y properties		
			}
		}
		
		private static function getNextIJ(i:int, j:int, directiona:String):Object
		{
			var resultI:int;
			var resultJ:int;
			
			if (directiona == "right")    
			{
				resultI = (i == SnakeData.FIELD_WIDTH - 1)? -1: i + 1;
				resultJ = j;
			}
			else if (directiona == "left")  
			{
				resultI = (i == 0)?SnakeData.FIELD_WIDTH:i - 1;
				resultJ = j;
			}
			else if (directiona == "down") 
			{
				resultI = i;
				resultJ = (j == SnakeData.FIELD_HEIGHT - 1)? -1:j + 1;
			}
			else if (directiona == "up")  
			{
				resultI = i;
				resultJ = (j == 0)?SnakeData.FIELD_HEIGHT:j - 1;
			}
			return { i:resultI, j:resultJ };
		}
		
		public function tryTurn():void 
		{		
			if (_type == "body" && _futureTurns.length > 0 && _futureTurns[0].doubleTurn)
			{	
				var oneCellForward:Object = SnakeData.forwardCell(_i, _j, _direction);
				if (oneCellForward.i == _futureTurns[0].i && oneCellForward.j == _futureTurns[0].j) //without finishing animation move 1 cell forward, turn, and make a new turn
				{					
					if (_reverseMe) _graphics.scaleX *= -1;//flip mc horizontally;			
					for (var i:int = 0; i < SnakeData.PART_SIZE / STEP_SIZE; i++) changePosition(); //move 1 cell forward	
					direction = _turnDirection;
					performTurn();
				}
			}
			else if (_futureTurns.length > 0 && _futureTurns[0].i == _i && _futureTurns[0].j == _j) performTurn(); //make a turn	
		}
		
		public function performTurn():void 
		{			
			_graphics.gotoTurn(_withHead); //withHead - for 1st body part. Thus under the head_mc will be no body-at-angle-state
			
			_turnDirection = _futureTurns[0].direction;
			_turnCounter = SnakeData.PART_SIZE / STEP_SIZE; //don't move 1 cell, just play animation. No need 2 "move" 24 times.
			
			if (type == "body") 
			{		
				_turnCounter = (SnakeData.PART_SIZE / STEP_SIZE) * 2;//body animation is 2-cell-length animation
				_doubleTurn = _futureTurns[0].doubleTurn; 
				if (_futureTurns[0].doubleTurn) _graphics.gotoDoubleturn(_withHead);			
			}				
			if ((_direction == "up" && _futureTurns[0].direction == "left") || (_direction == "left" && _futureTurns[0].direction == "down") || (_direction == "down" && _futureTurns[0].direction == "right") || (_direction == "right" && _futureTurns[0].direction == "up"))
			{
				_graphics.scaleX *= -1;//flip mc horizontally
				_reverseMe = true;
			}
			else _reverseMe = false;	
			
			_turnCounter--;
			_futureTurns.shift(); //don't need turn object anymore
		}
		
		public function turnToTail():void //turning body into tail
		{			
			if (_turnCounter == -1) //passive state, no turn
			{
				createTail();
				_graphics.mc.gotoAndStop(1);
			}
			else if (_turnCounter < SnakeData.PART_SIZE / STEP_SIZE) //finishing turn 
			{		
				createTail();
				_graphics.gotoTurn(false);
				for (var i:int = 0; i < SnakeData.PART_SIZE / STEP_SIZE; i++)
                {
                    move(); //move 1 cell forward
                }
				//_graphics.mc.gotoAndStop(lastFrame);	//goto the same frame as body was			
			}
			else if (_turnCounter > (SnakeData.PART_SIZE / STEP_SIZE) - 1) //turn is at it's 1st part: move 1 cell frwrd, substitute body -> tail 
			{	
				trace("_turnDirection: " + _turnDirection + " growmodecoutner: " + _growModeCounter + " _turnCounter: " + _turnCounter);
				changeRealCoordinates();
				for (var j:int = 0; j < SnakeData.PART_SIZE / STEP_SIZE; j++)
                {
                    move(); //move 1 cell forward
                }
				var lastFrame:int;
				if (_graphics.currentFrame > 18)
                {
                    lastFrame = 9 - (25 - _graphics.currentFrame);
                } //doubleturn. 9 = (10 (maxFrames in tail) - 1(for array index)). 9 - amount of frames left to finish at doubleturn.
				else
                {
                    lastFrame = 9 - (17 - _graphics.currentFrame);
                } //usual turn.9 (10 - 1) (max frames) - frames left to turnFinish
				createTail();
				_graphics.mc.gotoAndStop(lastFrame);	//goto the same frame as body was	
			}		
		}
		
		private function createTail():void		
		{
			var scalX:Number = _graphics.scaleX;
			removeChild(_graphics);
			_type = "tail";
			createGraphics("tail");	
			direction = _direction; //update mc rotation
			_graphics.scaleX = scalX; // set previous scale to new graphics
		}
		
		public function setGrowModeCounter():void { _growModeCounter = SnakeData.PART_SIZE / STEP_SIZE; }
		
		public function set direction(value:String):void { _direction = value; 
			if (value == "right")	_graphics.rotation = 90;
			else if (value == "down") _graphics.rotation = 180;
			else if (value == "left") _graphics.rotation = 270;
			else if (value == "up") _graphics.rotation = 0;
		}
		public function set j(value:int):void {	_j = value;}	
		public function set i(value:int):void {	_i = value;}
		public function set futureTurns(value:Array):void {	_futureTurns = value; }
		public function set doubleTurn(value:Boolean):void 	{ _doubleTurn = value; }
		public function set reverseMe(value:Boolean):void {	_reverseMe = value;	};
		public function set turnCounter(value:int):void { _turnCounter = value;	}
		public function set turnDirection(value:String):void {	_turnDirection = value;	}	
		
		public function get j():int { return _j; }
		public function get i():int { return _i; }						
		public function get color():int {	return _color; }			
		public function get direction():String { return _direction;	}	
		public function get doubleTurn():Boolean { return _doubleTurn;	}	
		public function get futureTurns():Array {return _futureTurns; }	
		public function get growModeCounter():int {	return _growModeCounter; }					
		public function get itemGraphics():SnakePartGraphic { return _graphics; }		
		public function get reverseMe():Boolean { return _reverseMe; }			
		public function get turnCounter():int { return _turnCounter; }	
		public function get turnDirection():String { return _turnDirection;	}	
		public function get type():String { return _type; }		
		public function get realJ():int { return _realJ; }		
		public function set realJ(value:int):void {_realJ = value;	}	
		public function get realI():int { return _realI; }		
		public function set realI(value:int):void {	_realI = value;	}
		public function get realFutureTurns():Array {return _realFutureTurns;	}		
		public function set realFutureTurns(value:Array):void {_realFutureTurns = value;}		
		public function get realDirection():String {return _realDirection;	}						
		public function set realDirection(value:String):void {	_realDirection = value;	}	
		public function get withHead():Boolean {return _withHead;}		
		public function set withHead(value:Boolean):void {_withHead = value;}
	}
}