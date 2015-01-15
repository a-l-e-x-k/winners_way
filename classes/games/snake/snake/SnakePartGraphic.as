package games.snake.snake 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import games.snake.SnakeData;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class SnakePartGraphic extends Sprite
	{
		private var _frames:Array = [];
		private var _currentFrame:int = 0;
		private var _mc:MovieClip;
		private var _type:String;
		private var _color:uint;
		private var _areaMask:Shape;
		//1 frame - default. 2 - turn start. 10 - turn finish. 19 - doubleTurn (body only)
		
		public function SnakePartGraphic(type:String, movieClip:MovieClip, color:uint) 
		{			
			_color = color;
			_type = type;
			_mc = movieClip;
			addChild(_mc);
			
			tryColorise();
			
			if (type == "body") //all that fancy bitmapisation is for body only. So turns animation is played easier 
			{	
				var translateMatrix:Matrix = new Matrix();	
				translateMatrix.translate(40, 40); //so bitmap draws from left top corner to the right down corner (by default it would start from the mc-middle (reg. point))			
				
				for (var i:int = 1; i <= _mc.totalFrames; i++ )
				{
					_mc.gotoAndStop(i);
					tryColorise();					
					
					var bitmapData:BitmapData = new BitmapData(80, 80, true, 0);
					bitmapData.draw(movieClip, translateMatrix);
					
					var converted:Sprite = new Sprite();
					converted.addChild(new Bitmap(bitmapData));	//for reg point setting later		
					_frames.push(converted);
					addChild(converted);
					
					Misc.setRegistrationPointForSnake(converted, 40, 40, false);	
					converted.alpha = 0;	
				}			
				
				removeChild(_mc);
				_mc = null;
				_frames[0].alpha = 1;
			}
			
			
			_areaMask = new Shape(); 
			_areaMask.graphics.beginFill(0x000000, 0);
			_areaMask.graphics.drawRect(-SnakeData.PART_SIZE/2 + 4, -SnakeData.PART_SIZE/2 - 5, 16, 34);
			_areaMask.graphics.endFill();
			addChild(_areaMask);
		}
		
		public function finishTurn():void
		{
			if (_type == "body")
			{
				_frames[_currentFrame].alpha = 0;		
				_frames[0].alpha = 1;
				_currentFrame = 0;
			}			
			else 
			{
				_mc.gotoAndStop("default");
				tryColorise();
			}
		}
		
		public function gotoTurn(withHead:Boolean):void
		{
			if (_type == "body")
			{			
				_frames[_currentFrame].alpha = 0;
				_frames[withHead?26:1].alpha = 1;
				_currentFrame = withHead?26:1;		
			}
			else 
			{
				_mc.gotoAndStop("turn");
				tryColorise();
			}
		}
		
		public function gotoDoubleturn(withHead:Boolean):void
		{		
			_frames[_currentFrame].alpha = 0;
			if (!withHead) _frames[18].alpha = 1;
			_currentFrame = 18;	
			
		}		
		
		public function nextFrame(withHead:Boolean):void
		{
			if (_type == "body")
			{		
				_frames[_currentFrame].alpha = 0;
				if (_currentFrame != 25) 
				{
					if (_currentFrame != 34) //==34 if 1st body & turning with head
					{
						_frames[_currentFrame + 1].alpha = 1;
						_currentFrame++;		
					}
					else //goto part2
					{
						_frames[10].alpha = 1;
						_currentFrame = 10;		
					}					
				}
				else //doubleturn
				{
					
					_frames[10].alpha = 1;
					_currentFrame = 10;
				}
				if (withHead && _currentFrame > 17 && _currentFrame < 26) _frames[_currentFrame].alpha = 0; //don't show body-angle at doubleturn when it's firstBody && turning with head
			}
			else 
			{
				_mc.nextFrame();			
				tryColorise();
			}			
		}
		
		private function tryColorise():void
		{
			if (_mc.getChildByName("stripe_mc") != null) Misc.applyColorTransform((_mc.getChildByName("stripe_mc") as MovieClip).color_mc, Misc.POSSIBLE_COLORS[_color]);
			if (_mc.getChildByName("stripe2_mc") != null) Misc.applyColorTransform((_mc.getChildByName("stripe2_mc") as MovieClip).color_mc, Misc.POSSIBLE_COLORS[_color]);
			if (_mc.getChildByName("mc_mc") != null && _mc.mc_mc.getChildByName("color_mc") != null) Misc.applyColorTransform((_mc.getChildByName("mc_mc") as MovieClip).color_mc, Misc.POSSIBLE_COLORS[_color]);
		}
		
		public function set currentFrame(value:int):void
		{		
			_currentFrame = value; 
			for each (var item:Sprite in _frames) item.alpha = 0;
			_frames[_currentFrame].alpha = 1;
		}
		
		public function clearUp():void
		{
			for each (var frame:Sprite in _frames)
			{
				(frame.getChildAt(0) as Bitmap).bitmapData.dispose(); //removing bitmap data manually
			}
		}
		
		public function get mc():MovieClip {return _mc;	}		
		public function get currentFrame():int {return _currentFrame;}						
		
		public function get areaMask():Shape 
		{
			return _areaMask;
		}
	}
}