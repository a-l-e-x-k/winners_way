package popups 
{
    import events.RequestEvent;

    import flash.display.Bitmap;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.filters.BlurFilter;

    import caurina.transitions.Tweener;

    /**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public class Popup extends MovieClipContainer
	{
		protected var _screenshot:Bitmap;
		public var _blurred:Sprite;
		protected var dispatchable:Boolean = true;
		
		public function Popup(child:MovieClip = null, x:Number = 0, y:Number = 0, closeByOkay:Boolean = false, noTweening:Boolean = false) 
		{			
			if (child != null) 
			{
				super(child, x, y, true);
				_mc.scaleX = _mc.scaleY = 0;
			}
			
			_blurred = new Sprite();
			_blurred.addEventListener(MouseEvent.CLICK, dispatchRemove);		
			addChild(_blurred);
			
			var f:Function;
			addEventListener(Event.ADDED_TO_STAGE, f = function(e:Event):void
			{
				removeEventListener(Event.ADDED_TO_STAGE, f);
				createStuff(child, closeByOkay, noTweening);
			});		
		}
		
		private function createStuff(child:MovieClip = null, closeByOkay:Boolean = false, noTweening:Boolean = false):void 
		{			
			_screenshot = Misc.snapshotStage();
			_screenshot.filters = [new BlurFilter(6, 6, 3)];
			_screenshot.alpha = 0;		
			
			var sceenshotCopy:Bitmap = new Bitmap(_screenshot.bitmapData.clone()); //so it won't be visible that stuff on stage was removed while _screenshot alpha is < 1
			_blurred.addChild(sceenshotCopy);
			_blurred.addChild(_screenshot);
			
			if (child != null) 
			{				
				if (noTweening) _mc.scaleX = _mc.scaleY = 1;
				else playScaleTween();
				
				setChildIndex(_mc, numChildren - 1); //so _mc is on top of blurred stuff
			}
			
			_blurred.x = -this.x;
			_blurred.y = -this.y;			
			
			if (_mc!= null && _mc.close_btn != null)
            {
                _mc.close_btn.addEventListener(MouseEvent.CLICK, dispatchRemove);
            }
			if (closeByOkay && _mc.ok_btn != null)
            {
                _mc.ok_btn.addEventListener(MouseEvent.CLICK, dispatchRemove);
            }
			
			Tweener.addTween(_screenshot, { alpha:1, time:noTweening?0:2, transition:"easeOutExpo", onComplete:function() { _blurred.removeChild(sceenshotCopy); } } );
		}
		
		public function playScaleTween():void 
		{
			_mc.scaleX = _mc.scaleY = 0;
			Tweener.addTween(_mc, { scaleX:1, time:0.4, transition:"easeOutExpo" } );
			Tweener.addTween(_mc, { scaleY:1, time:0.4, transition:"easeOutExpo" } );
		}
		
		public function dispatchRemove(e:Event = null):void 
		{
			_screenshot.bitmapData.dispose();
			if (dispatchable) dispatchEvent(new RequestEvent(RequestEvent.REMOVE_ME, {}));
		}
		
		public function showLoading(emptyTextfield:Boolean = false):void
		{
			if (_mc != null) removeChild(_mc);
			_blurred.removeEventListener(MouseEvent.CLICK, dispatchRemove);
			_mc = new loadingAnim();
			_mc.x = Misc.GAME_AREA_WIDTH / 2;
			_mc.y = Misc.GAME_AREA_HEIGHT / 2;
			if (emptyTextfield) _mc.message_txt.text = "";
			addChild(_mc);
		}
		
		public function get screenshot():Bitmap { return _screenshot; }		
	}
}