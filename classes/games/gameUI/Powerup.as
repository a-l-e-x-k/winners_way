package games.gameUI 
{
    import events.RequestEvent;

    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    import flash.utils.getDefinitionByName;

    import caurina.transitions.Tweener;

    /**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class Powerup extends MovieClipContainer
	{
		private var _amount:int = 0;
		private var _timeMask:TimeMask;		
		private var _startDate:Date = new Date((new Date()).time - 200000); // -200k so there is a gap for _lifetime check to work
		private var _lifeTime:int;
		private var _totalTime:int;
		private var _useMePopup:MovieClip;
		private var _usedOnce:Boolean = false; //if used once before showing "useMe" -> "useMe" won't be shown
		private var _infoPopup:InfoPopup;
		private var _showInfoTimer:Timer = new Timer(400, 1);
		private var _lockedMC:MovieClip;
		
		public function Powerup(name:String, i:int) 
		{		
			super(new itemContainer(), 7, 572);
			x = 7 + i * (_mc.width + 5);
			
			_lockedMC = new locked();
			
			_lifeTime = PowerupsManager.getPowerupLifetime(name);
			_totalTime = PowerupsManager.getPowerupTime(name);
			
			var assetClass:Class = getDefinitionByName(name) as Class;
			var picture:MovieClip = new assetClass();
			_mc.mc.pic_mc.addChild(picture);				
			
			_timeMask = new TimeMask(picture.width / 2, picture.height / 2);
			_timeMask.rotation = 270;
			_mc.mc.pic_mc.addChild(_timeMask); 		
			
			var shorcut:MovieClip = new powerupshortcut();
			shorcut.key_txt.text = String(i + 1);			
			_mc.mc.border_mc.addChild(shorcut);
			
			this.name = name;
			if (this.name == "undo") _lifeTime = 99999999; //undo is possible from 2nd turn			
			
			if (PowerupsManager.meZero(this.name) && PowerupsManager.infinityExpires == -1)
			{
				_timeMask.updatePicture(0);
				turnOff();
			}
			
			_infoPopup = new InfoPopup(name);
			_infoPopup.visible = false;
			addChild(_infoPopup);
			
			_useMePopup = new useMePop();
			_useMePopup.alpha = 0;
			_useMePopup.x = 3;
			_useMePopup.y = 10;
			if (Lingvo.dictionary.LANGUAGE == "RUS") _useMePopup.bg.gotoAndStop(2);
			addChild(_useMePopup);					
			
			var showUseMeTimer:Timer = new Timer(PowerupsManager.getPowerupShowUseMeTime(name), 1);
			showUseMeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, dispatchTimerComplete);
			showUseMeTimer.start();
			
			_showInfoTimer.addEventListener(TimerEvent.TIMER_COMPLETE, showInfo);
			
			addEventListener(MouseEvent.CLICK, dispatchClick); //can't use powerup at lobby :)
			addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void { _showInfoTimer.start(); } );
			addEventListener(MouseEvent.ROLL_OUT, hideInfo);			
		}
		
		private function showInfo(e:TimerEvent):void 
		{
			_infoPopup.visible = true;
		}
		
		private function hideInfo(e:MouseEvent):void
		{
			_showInfoTimer.reset();
			_infoPopup.visible = false;
		}
		
		private function dispatchTimerComplete(e:TimerEvent):void 
		{
			dispatchEvent(new RequestEvent(RequestEvent.TRY_USE_ME));
		}
		
		public function showUseMe():void
		{
			if (!_usedOnce)
			{
				Tweener.addTween(_useMePopup, { y: _useMePopup.height + 1, time:0.7, transition:"easeOutBounce", onComplete:function():void {
					var repeatJumpingTimer:Timer = new Timer(9000);
					repeatJumpingTimer.addEventListener(TimerEvent.TIMER, function(e:Event):void { //repeats jumping each 7 seconds
						
						Tweener.addTween(_useMePopup, { y:20, time:0.1, transition:"easeOutSine", onComplete:function():void {
							Tweener.addTween(_useMePopup, { y: _useMePopup.height + 1, time:0.5, transition:"easeOutBounce" } );
						}} );
					});
					repeatJumpingTimer.start();
				}});			
				Tweener.addTween(_useMePopup, { alpha:1, time:0.4, transition:"easeOutSine" } );
			}
		}
		
		private function hideUseMe():void
		{
			Tweener.addTween(_useMePopup, { y:80, time:0.5, transition:"easeOutSine" } );			
			Tweener.addTween(_useMePopup, { alpha:0, time:0.4, transition:"easeOutSine" });
		}
		
		private function dispatchClick(e:MouseEvent):void 
		{
			dispatchEvent(new RequestEvent(RequestEvent.USE_POWERUP, { }, true)); //Game.as makes all the checks.
		}
		
		public function useMe():void
		{
			_usedOnce = true;
			_amount--;
			if (this.name != "grid")
			{				
				_startDate = new Date();
				if (_amount > 0  || PowerupsManager.infinityExpires != -1) addEventListener(Event.ENTER_FRAME, onEnterFrame);
				else
				{
					if (_lifeTime > 0) addEventListener(Event.ENTER_FRAME, onEnterFrame);
					else turnOff();
				}
			}
			else turnOff();
			PowerupsManager.usePowerup(this.name);
			hideUseMe();
			dispatchEvent(new RequestEvent(RequestEvent.WAS_USED));
		}
		
		private function onEnterFrame(e:Event):void 
		{
			var now:Date = new Date();
			if ((now.time - _startDate.time) <= _lifeTime) _timeMask.updatePicture(360 - 360 * ((now.time - _startDate.time) / _lifeTime), true); 
			else if ((now.time - _startDate.time) > _lifeTime && (now.time - _startDate.time) <= _totalTime) 
			{
				if (_amount > 0 || PowerupsManager.infinityExpires != -1) 
				{					
					_timeMask.updatePicture(360 - 360 * ((now.time - _startDate.time - _lifeTime) / (_totalTime - _lifeTime)));		
				} 
				else  //if using finished & it was last powerup				
				{
					removeEventListener(Event.ENTER_FRAME, onEnterFrame);
					_timeMask.updatePicture(0);
					turnOff();
				}				
			}
			else if ((now.time - _startDate.time) > _totalTime) //refilled
			{
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
				_timeMask.updatePicture(0);
			}
		}
		
		public function turnOn():void
		{
			Tweener.addTween(_lockedMC, { alpha:0, time:1, transition:"easeOutExpo" } );
		}
		
		public function turnOff():void
		{			
			if (!_mc.mc.pic_mc.contains(_lockedMC)) _mc.mc.pic_mc.addChild(_lockedMC); //only adding it when there is a need to lock a powerup. Usually there will be no lock there
			Tweener.addTween(_lockedMC, { alpha:1, time:1, transition:"easeOutExpo" } );
		}
		
		public function get usePossible():Boolean 	
		{
			var useTimerCompleted:Boolean = (((new Date).time - _startDate.time) > _totalTime);
			var amountEnough:Boolean = (_amount > 0 || PowerupsManager.infinityExpires != -1);
			return (useTimerCompleted && amountEnough);
		} //false if not enough amount || timer is still running	
		public function get useBoostPossible():Boolean 	{ return (((new Date).time - _startDate.time) > _lifeTime) } //false if not enough amount || timer is still running	
		public function set amount(amount:int):void { _amount = amount; }
		public function get amount():int {	return _amount;	}		
		public function set lifeTime(value:int):void {_lifeTime = value;	}
	}
}