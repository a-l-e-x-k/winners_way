package lobby.shop 
{
	import events.RequestEvent;
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import lobby.Lobby;
	import lobby.shop.coinAdder.CoinAdder;
	import lobby.shop.sections.shelves.powerupsShelf.BuyPowerupPopup;
	import lobby.shop.sections.Store;
	import popups.Popup;
	
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class Shop extends Popup
	{		
		private var _tabs:Tabs;
		private var _store:Store;
		private var _buyPopup:Popup;
		
		public function Shop(currentGame:String, powerupName:String) 
		{
			super(new shop(), 388, 280, false, powerupName != "");	//if showing "buy powerup " window (user clicked tiny "add" near the powerup) - no scaleX anim
			
			_mc.bg.logo_txt.text = Lingvo.dictionary.shopname();
			_mc.add_btn.bg.text_txt.text = Lingvo.dictionary.addCoins();
			_mc.add_btn.addEventListener(MouseEvent.MOUSE_UP, showCoinAdder);
			_mc.add_btn.buttonMode = true;
			_mc.cash_txt.text = UserData.coins;
			_mc.packs_txt.text = Lingvo.dictionary.inpacks();
			_mc.unlim_txt.text = Lingvo.dictionary.unlimitedpowerups();
			_mc.forall_txt.text = Lingvo.dictionary.forAllGames();
			if (Networking.socialNetworker.ACRONYM == Networking.FB) _mc.forall_txt.x = 133;
			Misc.addSimpleButtonListeners(_mc.add_btn);	
			
			_tabs = new Tabs(currentGame);
			_tabs.addEventListener(RequestEvent.SWITCH_TAB, switchTab);
			_mc.addChild(_tabs);
			
			_store = new Store(currentGame);
			_store.addEventListener(RequestEvent.BUY_POWERUP, createPopup);
			_mc.bg.container_mc.addChild(_store);
			
			if (powerupName != "") Misc.delayCallback(function() { createPopup(new RequestEvent(RequestEvent.BUY_POWERUP, {name:powerupName, goodType:"powerup"})); }, 200);			
			Networking.socialNetworker.eventDispatcher.addEventListener(RequestEvent.BALANCE_CHANGED, updateBalanceTF);
		}			
		private function switchTab(e:RequestEvent):void 
		{			
			_store.gotoGame(e.stuff.name);
		}	
		
		private function showCoinAdder(e:Event):void 
		{
			trace("showCoinAdder");			
			if (Networking.socialNetworker.ACRONYM == Networking.FB) Networking.socialNetworker.showCoinAdder(); //at VK Networker may create coinAdded (which is now deleted) and add it to stage.
			else
			{
				var coinAdder:CoinAdder = new CoinAdder();
				coinAdder.addEventListener(RequestEvent.REMOVE_ME, function(e:RequestEvent) { removeChild(coinAdder); } );
				coinAdder.addEventListener(RequestEvent.BALANCE_CHANGED, updateBalanceTF);
				addChild(coinAdder);
			}
		}
		
		private function createPopup(e:RequestEvent):void
		{			
			t.obj(e.stuff);
			
			if (e.stuff.goodType == "powerup")
			{
				_buyPopup = new BuyPowerupPopup(e.stuff.name);	
			}
			else if (e.stuff.goodType == "pack" || e.stuff.goodType == "infinity")
			{
				_buyPopup = new BuyPopup(e.stuff.index.toString(), e.stuff.goodType);				
			}
			_buyPopup.addEventListener(RequestEvent.BUY_POWERUP, removePopup);
			_buyPopup.addEventListener(RequestEvent.SHOW_COIN_ADDER, showCoinAdder);
			_buyPopup.addEventListener(RequestEvent.REMOVE_ME, removePopup);			
			addChild(_buyPopup);
		}
		
		private function removePopup(e:RequestEvent):void 
		{
			trace("Item bought. Adding to client vault");
			t.obj(e.stuff);
			
			if (e.stuff != null) //if event is BUY_POWERUP
			{				
				_mc.cash_txt.text = UserData.coins;
				
				if (e.stuff.goodType == "powerup") PowerupsManager.addPowerup(e.stuff.goodName, e.stuff.amount);
				else if (e.stuff.goodType == "pack") PowerupsManager.addPack(int(e.stuff.goodName)); //index of pack & gameName. With this data PowerupManager can get Pack info
				else if (e.stuff.goodType == "infinity") PowerupsManager.goInfinite(e.stuff.goodName);
				
				(this.parent as Lobby).powerupsInfo.updateAmounts();
			}
			
			removeChild(_buyPopup);
			_buyPopup = null;
		}
		
		private function updateBalanceTF(e:RequestEvent):void 
		{
			_mc.cash_txt.text = UserData.coins;
		}
	}
}