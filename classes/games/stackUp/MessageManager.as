package games.stackUp 
{
    import flash.events.Event;
    import flash.events.TimerEvent;
    import flash.utils.Timer;

    import caurina.transitions.Tweener;

    /**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class MessageManager extends MovieClipContainer 
	{
		private var _users:Array; //link to users at StackUpGame.as
		private var _timer:Timer = new Timer (1000, 1);			
		
		public function MessageManager(users:Array) 
		{			
			super(new messagePopup(), 420, 250);
			_mc.alpha = 0;
			_users = users;
		}
		
		public function showNextTurn(whoseTurnID:String):void
		{
			if (whoseTurnID == UserData.id)
			{
				_mc.message_txt.text = Lingvo.dictionary.yourTurn();
			}
			else 
			{
				var dudeName:String = "";
				
				for (var i:int = 0; i < _users.length; i++) 
				{
					if (_users[i].id == whoseTurnID) 
					{
						dudeName = _users[i].name;
						break;
					}
				}
				
				_mc.message_txt.text = Lingvo.dictionary.turnOf() + " " + dudeName;
			}		
			
			alphaOn();
			_timer.addEventListener(TimerEvent.TIMER_COMPLETE, alphaOff);
			_timer.start();	
		}
		
		public function tryShowReeling():void
		{
			if (_mc.message_txt.text == Lingvo.dictionary.reeling())
                return;

            _mc.message_txt.text = Lingvo.dictionary.reeling();
            alphaOn();
		}
		
		public function showAsyncError():void
		{
			_mc.message_txt.text = Lingvo.dictionary.asyncError();
			alphaOn();
		}
		
		private function alphaOn():void
		{
			Tweener.addTween(_mc, { alpha:1, time:0.35, transition:"easeOutCubic" } );
		}
		
		public function alphaOff(e:Event = null):void
		{
			Tweener.addTween(_mc, { alpha:0, time:0.35, transition:"easeOutCubic" } );
		}
	}
}