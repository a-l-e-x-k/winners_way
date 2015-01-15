package lobby.myWay 
{
    import events.RequestEvent;

    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.utils.Timer;

    import caurina.transitions.Tweener;

    /**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class MyWayButton extends MovieClipContainer 
	{
		private var showInfoTimer:Timer = new Timer(700, 1);
		
		public function MyWayButton() 
		{
			super(new mystorybtn(), 155, 5);
			_mc.bg.eng_mc.visible = Lingvo.dictionary.LANGUAGE == "ENG";
			_mc.bg.rus_mc.visible = Lingvo.dictionary.LANGUAGE == "RUS";
			this.buttonMode = true;
			
			_mc.addEventListener(MouseEvent.CLICK, dispatchClick);
			_mc.addEventListener(MouseEvent.ROLL_OVER, onOver);
			_mc.addEventListener(MouseEvent.ROLL_OUT, onOut);
			_mc.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			Networking.client.stage.addEventListener(MouseEvent.MOUSE_MOVE, tryUpdateInfoPop);
			
			setProgress();
			
			showInfoTimer.addEventListener(TimerEvent.TIMER_COMPLETE, showInfo);
		}		
		
		private function tryUpdateInfoPop(e:MouseEvent):void 
		{
			_mc.completed_mc.x = mouseX;
			_mc.completed_mc.y = mouseY - this.y;
		}
		
		private function showInfo(e:TimerEvent):void 
		{
			Tweener.addTween(_mc.completed_mc, { alpha:1, time:0.5, transition:"easeOutSine" } );
		}
		
		private function hideInfo():void 
		{
			showInfoTimer.reset();
			Tweener.addTween(_mc.completed_mc, { alpha:0, time:0.1, transition:"easeOutSine" } );
		}
		
		private function setProgress():void 
		{
			trace("getStoryCompletedLength: " + StoryManager.getStoryCompletedLength());
			trace("getStoryLength: " + StoryManager.getStoryLength());
			var percentCompleted:Number = StoryManager.getStoryCompletedLength() / StoryManager.getStoryLength();
			trace("percentCompleted: " + percentCompleted);
			_mc.bg.bar_mc.x = 450 * percentCompleted;
			_mc.completed_mc.text_txt.text = Math.round(percentCompleted * 100) + "% " + Lingvo.dictionary.completed();
		}
		
		private function dispatchClick(e:MouseEvent):void 
		{
			if (Misc.definitionExists("level" + StoryManager.currentLevel)) dispatchEvent(new RequestEvent(RequestEvent.IMREADY));
		}
		
		private function onDown(e:MouseEvent):void 
		{
			e.currentTarget.gotoAndStop("down");
			hideInfo();
		}
		
		private function onOut(e:MouseEvent):void 
		{
			e.currentTarget.gotoAndStop("up");
			hideInfo();
		}
		
		private function onOver(e:MouseEvent):void 
		{
			showInfoTimer.start();
			e.currentTarget.gotoAndPlay("over");
		}
	}
}