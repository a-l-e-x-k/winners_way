package lobby.gameStart
{
	import events.RequestEvent;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class GameSelector extends MovieClipContainer
	{		
		public function GameSelector(gameName:String) 
		{
			super(new gameSelector(), 0, 0);
			
			_mc.wordSeekers.addEventListener(MouseEvent.CLICK, goToGame);
			_mc.snake.addEventListener(MouseEvent.CLICK, goToGame);
			_mc.stackUp.addEventListener(MouseEvent.CLICK, goToGame);
			
			_mc.wordSeekers.addEventListener(MouseEvent.ROLL_OVER, tryOnOver);	
			_mc.snake.addEventListener(MouseEvent.ROLL_OVER, tryOnOver);	
			_mc.stackUp.addEventListener(MouseEvent.ROLL_OVER, tryOnOver);	
			
			_mc.wordSeekers.addEventListener(MouseEvent.ROLL_OUT, tryOnOut);	
			_mc.snake.addEventListener(MouseEvent.ROLL_OUT, tryOnOut);	
			_mc.stackUp.addEventListener(MouseEvent.ROLL_OUT, tryOnOut);	
			
			_mc.stackUp.buttonMode = true;
			_mc.wordSeekers.buttonMode = true;
			_mc.snake.buttonMode = true;
			
			(_mc.getChildByName(gameName) as MovieClip).gotoAndStop("down");
			(_mc.getChildByName(gameName) as MovieClip).buttonMode = false;
			
			
			if ((!UserData.openedSnake) && (!UserData.openedStackUp) && (!UserData.openedWordSeekers)) 
			{
				_mc.click_txt.visible = true;
				var message:String = Lingvo.dictionary.intro();
				var typeTimer:Timer = new Timer(33, message.length);
				typeTimer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void
				{
					_mc.click_txt.text += message.charAt(typeTimer.currentCount - 1);
				});
				typeTimer.start();
			}
		}
		
		private static function tryOnOut(e:MouseEvent):void
		{
			if (e.currentTarget.currentFrameLabel != "down")
                e.currentTarget.gotoAndStop("up");
		}
		
		private static function tryOnOver(e:MouseEvent):void
		{
			if (e.currentTarget.currentFrameLabel == "up")
                e.currentTarget.gotoAndPlay("over");
		}
		
		private function goToGame(e:MouseEvent):void
		{
			if (e.currentTarget.currentFrameLabel != "down")
			{
				trySendOtherGamesTried();
				
				for (var i:int = 0; i < _mc.numChildren; i++ )
				{
					if (_mc.getChildAt(i) is MovieClip)
					{
						(_mc.getChildAt(i) as MovieClip).gotoAndStop("up");
						(_mc.getChildAt(i) as MovieClip).buttonMode = true;
					}					
				}
				e.currentTarget.gotoAndStop("down");				
				e.currentTarget.buttonMode = false;
				dispatchEvent(new RequestEvent(RequestEvent.CHANGE_GAME, { name:e.currentTarget.name }, true));
			}
		}		
		
		private static function trySendOtherGamesTried():void //if user by himself will try another game we should now about that and not show him tutorial on his 2nd victory
		{
			if (UserData.winCount < Misc.WINS_TILL_OTHER_GAMES_POPUP) //user tried other game without tutorial
			{
				if (Networking.connection != null) Networking.connection.send("tOG", 0);
				else Misc.delayCallback(trySendOtherGamesTried, 1000);
			}
		}
	}
}