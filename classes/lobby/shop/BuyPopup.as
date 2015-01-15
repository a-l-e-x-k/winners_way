package lobby.shop 
{
	import events.RequestEvent;
	import flash.events.MouseEvent;
	import playerio.Message;
	import popups.Popup;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public class BuyPopup extends Popup
	{
		protected var _goodType:String;
		protected var _goodName:String;
		protected var _amount:int = 1; //used at BuyPowerupPopup & is dispatched at showSuccess()
		
		public function BuyPopup(goodName:String, goodType:String) 
		{
			_goodType = goodType;
			_goodName = goodName;		
			trace("_goodName:" + _goodName);
			
			super();
			dispatchable = false;
			showLoading(true);			
			_mc.message_txt.text = Lingvo.dictionary.buying();
			doConnectionThings();
		}
		
		private function doConnectionThings():void 
		{			
			if (Networking.connection != null) 
			{
				Networking.connection.addMessageHandler("buyok", showSuccess);
				Networking.connection.addMessageHandler("buyne", showNotEnough);
				Networking.connection.addMessageHandler("payerr", showError);
				
				if (_goodType == "pack") //goodName here will be index of pack for the game (0, 1 or 2) => server knows all pack data. So by mesageType serv gets goodType, by itemId - exact good info for game which has gameId
				{
					Networking.trySend("buypa", int(_goodName));					
				}
				else if (_goodType == "infinity")
				{
					Networking.trySend("buyin", int(_goodName));
				}
			}
			else Misc.delayCallback(doConnectionThings, 200);
		}
		
		private function showSuccess(message:Message):void 
		{
			UserData.coins = message.getInt(0); //server sends 100% true balance 
			trace(message);
			_mc.message_txt.text = Lingvo.dictionary.success();
			removeListeners();			
			Misc.delayCallback(function():void { dispatchEvent(new RequestEvent(RequestEvent.BUY_POWERUP, { amount:_amount, goodName:_goodName, goodType:_goodType } )) }, 1500);
			dispatchable = false; //lock dispatch (no manual closing)
		}		
		
		private function showNotEnough(message:Message):void 
		{
			dispatchable = true;
			var notEnoughPop:NotEnough = new NotEnough();		
			notEnoughPop.mc.cancel_btn.addEventListener(MouseEvent.CLICK, function(eve:MouseEvent):void
			{
				removeListeners();
				dispatchEvent(new RequestEvent(RequestEvent.REMOVE_ME)); 
			});
			notEnoughPop.mc.add_btn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
			{ 
				removeListeners();
				dispatchEvent(new RequestEvent(RequestEvent.SHOW_COIN_ADDER)); //and Shop will show CoinAdder
				dispatchEvent(new RequestEvent(RequestEvent.REMOVE_ME)); 
			});//so Good will remove popup				
			addChild(notEnoughPop);
		}
		
		private function showError(message:Message):void 
		{
			trace(message);
			_mc.message_txt.text = Lingvo.dictionary.payerr();	
			removeListeners();
			Misc.delayCallback(function():void { dispatchEvent(new RequestEvent(RequestEvent.REMOVE_ME)) }, 1500);
		}
		
		private function removeListeners():void
		{
			Networking.connection.removeMessageHandler("buyok", showSuccess);
			Networking.connection.removeMessageHandler("buyne", showNotEnough);
			Networking.connection.removeMessageHandler("payerr", showError);
		}
	}

}