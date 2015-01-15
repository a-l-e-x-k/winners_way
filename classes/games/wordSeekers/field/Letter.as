package games.wordSeekers.field 
{
    import flash.events.Event;
    import flash.utils.getDefinitionByName;

    import caurina.transitions.Tweener;

    /**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class Letter extends MovieClipContainer
	{
		private var _selected:Boolean;
		private var _opened:Boolean;
		private var _j:int;
		private var _m:int;
		
		public function Letter(j:int, m:int, text:String) 
		{
			_m = m;
			_j = j;
			
			var assetClass:Class =  getDefinitionByName("bukva") as Class;
			super(new assetClass());
			x = m * (_mc.width + 2) + 10;
			y = j * (_mc.height - 0.6) + 9;
			_mc.mc.l.letter_txt.text = text;
		}
		
		public function showFail():void 
		{
			if 	(_selected)
			{
				_mc.blue_mc.addEventListener(Event.ENTER_FRAME, enterFrameFail);
				_mc.blue_mc.gotoAndPlay("fail");
			}
		}
		
		public function showWin(color:uint):void 
		{		
			_mc.gotoAndStop(3);
			_mc.blue_mc.gotoAndStop("win");
			Misc.applyColorTransform(_mc.blue_mc.color.color, color); //0x000000 - fix for black dude bug
			_mc.blue_mc.color.color.alpha = 0.57;
			_mc.blue_mc.addEventListener(Event.ENTER_FRAME, enterFrameWin);
			_mc.blue_mc.play();
			_selected = false;
			_opened = true;
		}
		
		public function finishAnimation():void //when all words opened need to finish "win" animation so printscreen will be good-looking
		{
			if (_opened && _mc.blue_mc != null && _mc.blue_mc.currentFrame < 60)
			{
				_mc.blue_mc.gotoAndStop(60);
			}
			else if (!_opened)
			{
				_mc.gotoAndStop(1);
			}
		}
		
		public function showYourself():void
		{
			_mc.attentioner_mc.play();		
		}
		
		public function goInvisible():void
		{
			Tweener.addTween(_mc, { alpha:0, time:1, transition:"easeOutExpo" } );
		}
		
		public function forceReset():void
		{
			_mc.gotoAndStop(1);
		}
		
		private function enterFrameWin(e:Event):void 
		{
			if (_mc.blue_mc.currentFrame == 60)
			{
				_mc.blue_mc.removeEventListener(Event.ENTER_FRAME, enterFrameWin);
				_mc.blue_mc.stop();				
			}
		}
		
		private function enterFrameFail(e:Event):void 
		{
			if (_mc.currentFrame == 3 && _mc.blue_mc.currentFrame == 30) 
			{
				_mc.blue_mc.removeEventListener(Event.ENTER_FRAME, enterFrameFail);
				_mc.blue_mc.gotoAndStop("fail");
				_selected = false;
				_mc.gotoAndStop(1);
			}
		}
		
		public function get selected():Boolean {	return _selected;}						
		public function get j():int {	return _j;}		
		public function get m():int {	return _m; }			
		public function get opened():Boolean { return _opened;	}
		
		public function set selected(value:Boolean):void {_selected = value;	}		
		public function set opened(value:Boolean):void {	_opened = value; }			
	}
}