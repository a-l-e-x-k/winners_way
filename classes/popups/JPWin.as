package popups 
{
	import caurina.transitions.Tweener;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class JPWin extends Popup 
	{
		
		public function JPWin(winnings:int) 
		{
			super(new jpwin(), 388, 316, true);
			_mc.winnings_txt.text = winnings;
			UserData.coins += winnings;
			UserData.streak = [];
			
			_mc.ok_btn.addEventListener(MouseEvent.ROLL_OVER, onOver);
			_mc.ok_btn.addEventListener(MouseEvent.ROLL_OUT, onOut);
			_mc.ok_btn.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			_mc.ok_btn.alpha = 0;
			_mc.ok_btn.text_txt.text = Lingvo.dictionary.superbtn();
			Tweener.addTween(_mc.ok_btn, { alpha:1, time:2, transition:"easeOutExpo" } );	
			_mc.ok_btn.addEventListener(MouseEvent.CLICK, dispatchRemove);
			
			_mc.won_txt.text = Lingvo.dictionary.youwonjp();
		}		
		
		private static function onDown(e:MouseEvent):void
		{
			e.currentTarget.gotoAndStop("down");
		}
		
		private static function onOut(e:MouseEvent):void
		{
			e.currentTarget.gotoAndStop("up");
		}
		
		private static function onOver(e:MouseEvent):void
		{
			e.currentTarget.gotoAndPlay("over");
		}
	}
}