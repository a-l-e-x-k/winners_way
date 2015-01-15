package games 
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class TimerPanel extends MovieClipContainer
	{
		private var _gameTimer:Timer = new Timer(1000);
		private var _timeOfStart:Date;	
		private var _gameLength:int;
		
		public function TimerPanel(gameLength:int) 
		{
			super(new gameTimer(), 331.2, Misc.GAME_AREA_Y);
			_gameLength = gameLength;			
		}
		
		public function startTimerGame():void
		{
			_gameTimer.addEventListener(TimerEvent.TIMER, fireTimer);				
			_timeOfStart = new Date();		
			_gameTimer.start();
			_mc.gotoAndStop(2);	
			_mc.label_txt.text = Lingvo.dictionary.beforeFinish();
		}
		
		public function startStackUp():void
		{
			_gameTimer.stop();
			_mc.gotoAndStop(3);		
			_mc.label_txt.text = Lingvo.dictionary.beforeFinishStackup();
		}
		
		public function goWhite()
		{
			_mc.label_txt.textColor = 0xFFFFFF;
			_mc.timer_txt.textColor = 0xFFFFFF;
		}
		
		private function fireTimer(e:TimerEvent):void 
		{
			var now:Date = new Date();
			var leftMs:int = _gameLength - (now.time - _timeOfStart.time); //difference in milliseconds
			if (leftMs > 0)
			{				
				var minutesLeft:int = Math.floor(leftMs / (60 * 1000));
				var secsLeft:int = Math.floor((leftMs - minutesLeft * 60 * 1000) / 1000);				
				_mc.timer_txt.text = ((int(minutesLeft) < 10)?"0" + minutesLeft.toString():minutesLeft.toString()) + ":" + ((int(secsLeft) < 10)?"0" + secsLeft.toString():secsLeft.toString());
			}
			else
			{
				_mc.timer_txt.text = "00:00";
				_gameTimer.removeEventListener(TimerEvent.TIMER, fireTimer );
				_gameTimer.stop();
			}
		}
	}

}