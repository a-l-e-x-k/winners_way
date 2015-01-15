package lobby.gameStart 
{
    import events.RequestEvent;

    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.utils.Timer;

    import popups.BeggingPopup;

    /**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class GameStart extends MovieClipContainer
	{
		private var _encouragePopup:BeggingPopup;
		
		public function GameStart(gameName:String) 
		{
			super(new gameStart(), 154, 100);
			mc.play_btn.text_txt.text = Lingvo.dictionary.play();
			addPlayBtnListeners();			
			
			addChild(new GameSelector(gameName));
			
			var showPopupTimer:Timer = new Timer(2000, 1);
			showPopupTimer.addEventListener(TimerEvent.TIMER_COMPLETE, tryShowPopup);
			showPopupTimer.start();
		}		
		
		private function tryShowPopup(e:TimerEvent):void 
		{
			if (!UserData.seenPopup)
			{
				UserData.seenPopup = true;
				_encouragePopup = new BeggingPopup();				
				_mc.popup_mc.addChild(_encouragePopup);				
			}
		}

		private function addPlayBtnListeners():void
		{
			mc.play_btn.addEventListener(MouseEvent.MOUSE_UP, goPlay);
			mc.play_btn.addEventListener(MouseEvent.ROLL_OVER, onOver);
			mc.play_btn.addEventListener(MouseEvent.ROLL_OUT, onOut);
			mc.play_btn.addEventListener(MouseEvent.MOUSE_DOWN, onDown);			
		}
		
		private static function onDown(e:MouseEvent):void
		{
			e.currentTarget.gotoAndStop("down");	
		}
		
		private static function onOut(e:MouseEvent):void
		{
			e.currentTarget.gotoAndPlay("up");
		}
		
		private static function onOver(e:MouseEvent):void
		{
			if (e.currentTarget.currentFrameLabel != "down") e.currentTarget.gotoAndStop("over");	
		}
		
		private function goPlay(e:MouseEvent):void 
		{
			dispatchEvent(new RequestEvent(RequestEvent.IMREADY));
		}			
	}
}