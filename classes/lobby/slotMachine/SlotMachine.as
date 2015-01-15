package lobby.slotMachine 
{
	import caurina.transitions.Tweener;
	import events.RequestEvent;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import popups.Popup;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class SlotMachine extends Popup
	{
		private var _activeSpinners:Array = [];
		private var _result:Array = []; //powerup type - amount array
		
		public function SlotMachine(giveAway:String, lastDay:int) 
		{		
			super(new slotMachine(), 351, 316, true);
			_mc.ok_btn.alpha = 0;
			_mc.label_txt.text = Lingvo.dictionary.giveaway();
			if (Lingvo.dictionary.LANGUAGE == "RUS") _mc.everyday_mc.bg.gotoAndStop(2);
			
			var today:Date = new Date();					
			var yesterday:Date = new Date(today.time - 24 * 60 * 60 * 1000);
			var ruinedStreak:Boolean = false;
			ruinedStreak = (yesterday.dateUTC != lastDay);
			trace("yesterday: " + yesterday.dateUTC + " lastDay: " + lastDay + " ruinedStreak: " + ruinedStreak);
			
			var giveAwayInfo:Array = giveAway.split(",");
			trace("giveAwayInfo before ");
			trace(giveAwayInfo);
			if (ruinedStreak) giveAwayInfo.splice(1, giveAwayInfo.length - 1); //in BigDB full-giveaway for next day is saved. Cut extra spinners here if not in-a-row visit. 
			trace("giveAwayInfo after ");
			trace(giveAwayInfo);
			
			for (var i:int = 0; i < 6; i++)
			{
				var spinner:Spinner = new Spinner(giveAwayInfo.length > i ? giveAwayInfo[i] : -1, i, i == giveAwayInfo.length - 1);
				if (i == giveAwayInfo.length - 1) spinner.addEventListener(RequestEvent.REMOVE_ME, addButton);
				if (giveAwayInfo.length > i) _activeSpinners.push(spinner);
				_mc.addChild(spinner);
			}
			
			Misc.delayCallback(go, 800); //400 ms will scaleX/Y animation						
			
			addGiveaway(giveAwayInfo);			
		}
		
		private function go():void 
		{
			for (var i:int = 0; i < _activeSpinners.length; i++) 
			{
				_activeSpinners[i].go();
			}
		}
		
		private function addGiveaway(giveAwayInfo:Array):void 
		{
			for (var j:int = 0; j < giveAwayInfo.length; j++) 
			{
				if (Misc.POSSIBLE_GIVEAWAY_ITEMS[giveAwayInfo[j]].indexOf("coins") != -1) //coins giveaway at this spinner
				{
					UserData.coins += int(Misc.POSSIBLE_GIVEAWAY_ITEMS[giveAwayInfo[j]].substring(0, Misc.POSSIBLE_GIVEAWAY_ITEMS[giveAwayInfo[j]].indexOf("c")));
				}
				else //powerup giveaway at this spinner
				{
					PowerupsManager.addPowerup(Misc.POSSIBLE_GIVEAWAY_ITEMS[giveAwayInfo[j]], 1);
				}
			}			
		}
		
		private function addButton(e:RequestEvent):void 
		{			
			_mc.ok_btn.text_txt.text = Lingvo.dictionary.ty();
			_mc.ok_btn.addEventListener(MouseEvent.ROLL_OVER, onOver);
			_mc.ok_btn.addEventListener(MouseEvent.ROLL_OUT, onOut);
			_mc.ok_btn.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			
			Tweener.addTween(_mc.ok_btn, { alpha:1, time:0.8, transition:"easeOutSine" } );
			dispatchable = true;
		}
		
		private function onDown(e:MouseEvent):void 
		{
			e.currentTarget.gotoAndStop("down");
		}
		
		private function onOut(e:MouseEvent):void 
		{
			e.currentTarget.gotoAndStop("up");
		}
		
		private function onOver(e:MouseEvent):void 
		{
			e.currentTarget.gotoAndPlay("over");
		}
		
		override public function dispatchRemove(e:Event = null):void 
		{
			_screenshot.bitmapData.dispose();
			if (dispatchable) dispatchEvent(new RequestEvent(RequestEvent.REMOVE_ME, {result:_result}));
		}
	}
}