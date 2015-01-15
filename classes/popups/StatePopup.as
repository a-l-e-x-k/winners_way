package popups 
{
    import events.RequestEvent;

    import caurina.transitions.Tweener;

    import flash.display.MovieClip;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.utils.Timer;

    /**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class StatePopup extends Popup
	{
		private var _showCloseTimer:Timer = new Timer(15000, 1);
		
		public function StatePopup(loadingPopup:Boolean = false) 
		{
			super();			
			showLoading();			
			_mc.message_txt.text = Lingvo.dictionary.loading();
			
			if (loadingPopup) 
			{
				_showCloseTimer.addEventListener(TimerEvent.TIMER_COMPLETE, showCloseBtn);
				_showCloseTimer.start();
			}
		}
		
		public function connecting():void { _mc.message_txt.text = Lingvo.dictionary.connecting(); }
		public function superStatus():void { _mc.message_txt.text = Lingvo.dictionary.superText(); }
		public function uploaderror():void { _mc.message_txt.text = Lingvo.dictionary.uploaderror(); }
		public function permissionsgranted():void { _mc.message_txt.text = Lingvo.dictionary.permissionsgranted(); }
		public function uploadingphotos():void { _mc.message_txt.text = Lingvo.dictionary.uploadingphotos(); }
		public function findingopponent():void { _mc.message_txt.text = Lingvo.dictionary.findingopponent(); }
		public function success():void { _mc.message_txt.text = Lingvo.dictionary.success(); }

		public function showPostButton():void
		{
			var button:MovieClip = new shButton();
			button.x = -74;
			button.y = 48;
			button.alpha = 0;
			button.addbtn_txt.text = Lingvo.dictionary.post();
			button.addEventListener(MouseEvent.ROLL_OVER, onOver);
			button.addEventListener(MouseEvent.ROLL_OUT, onOut);
			button.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			_mc.addChild(button);
			
			Tweener.addTween(button, { alpha:1, time:2, transition:"easeOutExpo" } );
			
			button.addEventListener(MouseEvent.CLICK, dispatchClick);
		}
		
		private function dispatchClick(e:MouseEvent):void 
		{
			e.currentTarget.removeEventListener(MouseEvent.CLICK, dispatchClick);
			Tweener.addTween(e.currentTarget, { alpha:0, time:1.5, transition:"easeOutExpo" } );
			dispatchEvent(new RequestEvent(RequestEvent.IMREADY)); 
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
		
		private function showCloseBtn(e:TimerEvent):void //if awaitimg opponent for 20 seconds -> allow user to manually close the button
		{
			_mc.closee_btn.visible = true;
			Tweener.addTween(_mc.closee_btn, { alpha:1, time:2, transition:"easeOutExpo" } );
			_mc.closee_btn.addEventListener(MouseEvent.CLICK, sendRemoveRequest);
		}
		
		private function sendRemoveRequest(e:MouseEvent):void 
		{
			Networking.trySend("gi"); //go invisible
			Networking.connection.addMessageHandler("gio", goInvisible);
		}
		
		private function goInvisible():void
		{
			Networking.connection.removeMessageHandler("gio", goInvisible);
			dispatchRemove();
		}
	}
}