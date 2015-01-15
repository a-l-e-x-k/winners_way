package lobby.shop.coinAdder 
{
    import events.RequestEvent;

    import popups.Popup;
    import popups.StatePopup;

    /**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public class CoinAdder extends Popup
	{
		public function CoinAdder()
		{
			super(new coinAdder(), 380, 335);
			
			_mc.logo_txt.text = Lingvo.dictionary.coinlogo();
			_mc.votes_txt.text = Lingvo.dictionary.votes();
			_mc.coins_txt.text = Lingvo.dictionary.coinsname();			
			
			var offers:Array = Networking.socialNetworker.offers;
			for (var i:int = 0; i < offers.length; i++) 
			{
				var coinOffer:CoinOffer = new CoinOffer(i, offers[i]);
				coinOffer.addEventListener(RequestEvent.IMREADY, tryWithdraw);
				_mc.addChild(coinOffer);
			}
		}
		
		private function tryWithdraw(e:RequestEvent):void
		{
			Networking.socialNetworker.eventDispatcher.addEventListener(RequestEvent.COINS_ADDED, showOK);
			Networking.socialNetworker.eventDispatcher.addEventListener(RequestEvent.ERROR_AT_ADDING_COINS, showError);
			Networking.socialNetworker.requestOfferData(e.currentTarget.i);		
		}
		
		private function showOK(e:RequestEvent):void 
		{
			var status:StatePopup = new StatePopup("super");
			Networking.client.stage.addChild(status);			
			Misc.delayCallback(function():void
			{							
				dispatchEvent(new RequestEvent(RequestEvent.BALANCE_CHANGED));
				Networking.client.stage.removeChild(status); 
			}, 2000);
		}
		
		private function showError(e:RequestEvent):void 
		{
			var status:StatePopup = new StatePopup("error");
			Networking.client.stage.addChild(status);
			Misc.delayCallback(function():void { Networking.client.stage.removeChild(status); }, 2000);
		}	
	}
}