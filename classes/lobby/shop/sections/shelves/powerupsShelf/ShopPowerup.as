package lobby.shop.sections.shelves.powerupsShelf 
{
	import events.RequestEvent;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.utils.getDefinitionByName;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class ShopPowerup extends MovieClipContainer 
	{
		private var _goodName:String;
		
		public function ShopPowerup(goodName:String, i:int, j:int) 
		{
			super(new good(), 0, 0);
			this.name = _goodName = goodName;
			x = -315 + i * (_mc.width + 21) + j * 750;
			y = -119;
			
			_mc.buy_btn.bg.text_txt.text = Lingvo.dictionary.buy();
			Misc.addSimpleButtonListeners(_mc.buy_btn);
			_mc.buy_btn.addEventListener(MouseEvent.CLICK, dispatchBuy);	
			_mc.buy_btn.buttonMode = true;
			_mc.price_txt.text = PowerupsManager.getPrice(_goodName);
			
			var assetClass:Class = getDefinitionByName(goodName) as Class;
			var picture:Sprite = new assetClass();
			picture.width = picture.height = 56;
			_mc.container_mc.addChild(picture);
		}
		
		public function dispatchBuy(e:MouseEvent = null):void 
		{			
			dispatchEvent(new RequestEvent(RequestEvent.BUY_POWERUP, { name:_goodName, goodType:"powerup" }, true ));				
		}		
	}
}