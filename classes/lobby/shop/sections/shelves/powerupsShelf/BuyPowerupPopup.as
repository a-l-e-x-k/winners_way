package lobby.shop.sections.shelves.powerupsShelf 
{
	import events.RequestEvent;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.getDefinitionByName;
	import lobby.shop.BuyPopup;
	
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class BuyPowerupPopup extends BuyPopup
	{
		var _popup:PowerupAmountSelector;
		
		public function BuyPowerupPopup(goodName:String) 
		{
			super(goodName, "powerup");
			
			
			addEventListener(Event.ADDED_TO_STAGE, function(e:Event) 
			{
				_mc.visible = false; //hide "processing" mc.
				dispatchable = true;
				_popup = new PowerupAmountSelector(goodName);
				_popup.addEventListener(RequestEvent.REMOVE_ME, dispatchRemove);
				_popup.mc.buy_btn.addEventListener(MouseEvent.CLICK, buy);
				addChild(_popup);
			});
		}
		
		private function buy(e:MouseEvent = null):void 
		{
			if (Networking.connection != null)
			{
				_amount = _popup.amount;
				Networking.trySend("buypo", _goodName, _popup.amount);	
				_mc.visible = true;
				_popup.visible = false;
			}
			else Misc.delayCallback(buy, 200);			
		}
	}
}