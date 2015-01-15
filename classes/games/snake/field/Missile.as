package games.snake.field 
{
    import events.RequestEvent;

    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.utils.getDefinitionByName;

    import games.snake.SnakeData;
    import games.snake.snake.Snake;
    import games.snake.snake.SnakePart;

    import caurina.transitions.Tweener;

    /**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class Missile extends MovieClipContainer
	{
		private var _targetHead:SnakePart;
		private var _targetX:int;
		private var _targetY:int;
		private var _velocityX:Number;
		private var _velocityY:Number;
		private var _speed:int = 0;
		private var _ease:int = 13;
		private var _assetClass:Class;
		private var _particlesCount:int = 0; //remove event dispatches only when all smoke disappears
		private var _targetCellData:Object;
		private var _boom:MovieClip;
		public var targetSnake:Snake; //used by event handler at MissileLauncher to put target snake to crazy state
		private var _launcherSnake:Snake; //used for checking match of target cell
		
		public function Missile(xx:Number, yy:Number, targetSnake:Snake, color:int, targetCellData:Object = null) 
		{
			this.targetSnake = targetSnake;
			_targetHead = targetSnake.head;
			_targetCellData = targetCellData;
			_assetClass = getDefinitionByName("missilething") as Class;
			super(new _assetClass, xx, yy, true);		
			_mc.rotation = -90;
			visible = false;					
			Misc.applyColorTransform(_mc.color_mc, Misc.POSSIBLE_COLORS[color]);	
			
			if (_targetCellData)
			{
				_launcherSnake = _targetCellData.launcher;
				_launcherSnake.dispatchExactlyCell = true;
				_launcherSnake.addEventListener(RequestEvent.EXACTLY_CELL, tryLaunch);
			}
			else go();
		}
		
		private function tryLaunch(e:RequestEvent):void 
		{
			if (SnakeData.checkPowerupTargetCell(e.stuff.previousHeadI, e.stuff.previousHeadJ, _launcherSnake.head.realI, _launcherSnake.head.realJ, _targetCellData))
			{
				_launcherSnake.removeEventListener(RequestEvent.EXACTLY_CELL, tryLaunch);
				_launcherSnake.dispatchExactlyCell = false;
				go();
			}
		}
		
		private function go():void //missile starts movement
		{
			visible = true;
			Tweener.addTween(this, { speed:11, time:2, transition:"easeOutExpo" } );
			dispatchEvent(new RequestEvent(RequestEvent.LAUNCHED));
		}
		
		public function updateMissile():void 
		{
			if (_mc.alpha != 0 && speed > 0) //if not after boom && started moving => may move && snake is not boosting and calling this func 2nd time
			{
				if (_mc.hit_mc.hitTestObject(_targetHead)) createBoom();
				else
				{
					_targetX = _targetHead.x - _mc.x;
					_targetY = _targetHead.y - _mc.y;
					
					var rotation:Number = Math.atan2(_targetY, _targetX) * 180 / Math.PI;
					
					if (Math.abs(rotation - _mc.rotation) > 180)
					{
						if (rotation > 0 && _mc.rotation < 0) _mc.rotation -= (360 - rotation + _mc.rotation) / _ease;
						else if (_mc.rotation > 0 && rotation < 0) _mc.rotation += (360 + rotation - _mc.rotation) / _ease;						
					}
					else if (rotation < _mc.rotation) _mc.rotation -= Math.abs(_mc.rotation - rotation) / _ease;
					else _mc.rotation += Math.abs(rotation - _mc.rotation) / _ease;
					
					_velocityX = _speed * (90 - Math.abs(_mc.rotation)) / 90;		
					if (_mc.rotation < 0) _velocityY = -_speed + Math.abs(_velocityX);
					else _velocityY = _speed - Math.abs(_velocityX);
					
					_mc.x += _velocityX;
					_mc.y += _velocityY;
				}
				
				updateTrail();
			}			
		}
		
		private function updateTrail():void 
		{
			_particlesCount++;
			_assetClass = getDefinitionByName("smokeparticle") as Class;
			var particle:MovieClip = new _assetClass();
			particle.x = _mc.x + Misc.randomNumber(3);
			particle.y = _mc.y + Misc.randomNumber(3);
			particle.rotation = Misc.randomNumber(360);
			particle.scaleX = particle.scaleY = ((Misc.randomNumber(50)/100) + 0.5);
			particle.speed = (Misc.randomNumber(6) + 2) / 100;
			particle.alpha = 0.01;
			Tweener.addTween(particle, {alpha:1, time:0.3, delay:0.1, transition:"linear", onComplete:function():void{particle.addEventListener(Event.ENTER_FRAME, onParticleEnterFrame);}}); //snake is not going from the head. Hence the tiny delay, so it looks like smoke from the tail
			addChild(particle);
		}
		
		private function onParticleEnterFrame(e:Event):void
		{
			e.currentTarget.scaleX += e.currentTarget.speed;
			e.currentTarget.scaleY += e.currentTarget.speed;
			e.currentTarget.alpha -= e.currentTarget.speed;
			if(e.currentTarget.alpha <= 0)
			{
				e.currentTarget.removeEventListener(Event.ENTER_FRAME, onParticleEnterFrame);
				removeChild(e.currentTarget as DisplayObject);			
				_particlesCount--;
				if (_boom != null && _boom.parent != null) removeBoom(); //remove firework animation even if it is not finished
				if (_particlesCount == 0) dispatchEvent(new RequestEvent(RequestEvent.REMOVE_ME));
			}
		}
		
		private function createBoom():void 
		{			
			trace("createBoom");
			Networking.connection.send("mibo"); //missile boom
			dispatchEvent(new RequestEvent(RequestEvent.IMREADY));
			_assetClass = getDefinitionByName("firework") as Class;
			_boom = new _assetClass();
			_boom.addEventListener(Event.ENTER_FRAME, onBoomEnter); //SnakeField will remove missile
			targetSnake.head.itemGraphics.mc.addChild(_boom);
			_mc.alpha = 0;
		}	
		
		private function onBoomEnter(e:Event):void 
		{
			if (_boom.currentFrame == _boom.totalFrames) removeBoom();
		}
		
		private function removeBoom():void
		{
			_boom.removeEventListener(Event.ENTER_FRAME, onBoomEnter);
			targetSnake.head.itemGraphics.mc.removeChild(_boom);
		}
		
		public function get speed():int 
		{
			return _speed;
		}
		
		public function set speed(value:int):void 
		{
			_speed = value;
		}
	}
}