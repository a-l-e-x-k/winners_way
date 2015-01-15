package lobby.powerupsInfo 
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
	public final class PowerupsInfo extends MovieClipContainer
	{
		private var _gameName:String;
		private var _allPowerups:Array = [];
		private var _infinityTimer:Timer;
		
		public function PowerupsInfo(gameName:String) 
		{
			super(new powerupsInfo(), 4.7, 99.4);
			_gameName = gameName;
			
			_mc.logo_txt.text = Lingvo.dictionary.mypowerups();
			_mc.add_btn.addbtn_txt.text = Lingvo.dictionary.add();
			_mc.add_btn.addEventListener(MouseEvent.ROLL_OVER, onOver);
			_mc.add_btn.addEventListener(MouseEvent.ROLL_OUT, onOut);
			_mc.add_btn.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			_mc.add_btn.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void { dispatchEvent(new RequestEvent(RequestEvent.SHOW_SHOP)); });
			_mc.add_btn.buttonMode = true;
			
			var infinityOn:Boolean = checkForInfinity();
			
			for (var m:int = 0; m < Misc.GAMES_NAMES.length; m++) //create all the powerups for every game
			{			
				var powerupsForGame:Array = PowerupsManager.getPowerupsForGame(Misc.GAMES_NAMES[m]);
				t.obj(powerupsForGame);
				for (var i:int = 0; i < powerupsForGame.length; i++)
				{
					var powerup:PowerupForLobby = new PowerupForLobby(powerupsForGame[i], i, m, 420); //424.05 - powerups panel height
					powerup.amount = PowerupsManager.powerups[PowerupsManager.POWERUPS.indexOf(powerupsForGame[i])].amount; //no infinity								
					_allPowerups.push(powerup);
					_mc.powerupsContainer_mc.addChild(powerup);					
					if (infinityOn) powerup.goInfinite();
				}
			}
			
			switchGame(gameName);
		}
		
		private function checkForInfinity():Boolean 
		{
			var infinityOn:Boolean = PowerupsManager.infinityExpires != -1;
			trace("infinityOn: " + infinityOn);
			_mc.infinityLeft_txt.visible = infinityOn;
			if (infinityOn)
			{
				var infinityExpiresAt:Number = PowerupsManager.infinityExpires;
				var secondsNow:Number = Math.round(((new Date()).time) / 1000);
				var secondsLeft:Number = infinityExpiresAt - secondsNow;
				var minutesLeft:Number = Math.ceil(secondsLeft / 60); //minutes are rounding up (so e.g. 20 seconds will be shown as "1 minute")				
				trace("secondsLeft: " + secondsLeft);
				
				//TODO: fix "ticking" too often (several listeners?)
				if (_infinityTimer != null) clearTimer();
				_infinityTimer = new Timer(60 * 1000, minutesLeft);
				_infinityTimer.addEventListener(TimerEvent.TIMER, updateInfinityTextfield);
				_infinityTimer.addEventListener(TimerEvent.TIMER_COMPLETE, turnInfinityOff);
				_infinityTimer.start();
				
				updateInfinityTextfield();
			}
			else _infinityTimer = null;
			return infinityOn;
		}
		
		private function clearTimer():void 
		{
			_infinityTimer.removeEventListener(TimerEvent.TIMER, updateInfinityTextfield);
			_infinityTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, turnInfinityOff);
			_infinityTimer = null;
		}
		
		private function updateInfinityTextfield(e:TimerEvent = null):void 
		{		
			var minutesLeftTotal:int = _infinityTimer.repeatCount - _infinityTimer.currentCount - (e == null ? 1 : 0);//minutes
			
			var daysLeft:int = Math.floor(minutesLeftTotal / (24 * 60));
			var hoursLeft:int = Math.floor((minutesLeftTotal - daysLeft * 24 * 60) / 60);
			var minutesLeft:int = minutesLeftTotal - daysLeft * 24 * 60 - hoursLeft * 60;
			
			trace("minutesLeft: " + minutesLeftTotal);
			
			_mc.infinityLeft_txt.text = Lingvo.dictionary.infinityExpires() + (daysLeft > 0 ? daysLeft + Lingvo.dictionary.d() + " " : "") + (hoursLeft > 0 ? hoursLeft + Lingvo.dictionary.h() + " ": "") + minutesLeft + Lingvo.dictionary.m();
		}
		
		private function turnInfinityOff(e:TimerEvent):void 
		{
			for (var j:int = 0; j < _allPowerups.length; j++) 
			{
				_allPowerups[j].goNormal();				
				_mc.infinityLeft_txt.visible = false;
				PowerupsManager.infinityExpires = -1;
			}
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
		
		public function switchGame(gameName:String):void
		{		
			Tweener.addTween(_mc.powerupsContainer_mc, { y: -Misc.GAMES_NAMES.indexOf(gameName) * 420, time:1, transition:"easeOutCubic"} ); //424.05 - powerups panel height
			
			_gameName = gameName;
			checkForInfinity(); //it'll hide/show infinity
		}
		
		public function updateAmounts():void
		{
			for (var i:int = 0; i < _allPowerups.length; i++) 
			{
				_allPowerups[i].amount = PowerupsManager.getPowerupAmount(_allPowerups[i].name);
			}
			
			if (checkForInfinity()) //e.g. if infinity was bought
			{
				for (var j:int = 0; j < _allPowerups.length; j++) 
				{
					_allPowerups[j].goInfinite();
				}
			}
		}
	}

}