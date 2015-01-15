package lobby.shop.coinAdder 
{
	import events.RequestEvent;
	import flash.events.MouseEvent;
	import flash.ui.Mouse;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public class CoinOffer extends MovieClipContainer
	{
		private var _i:int;
		
		public function CoinOffer(i:int, data:Object) 
		{
			super( new coinOffer(), -235, -113 + i * (41 + 7));
			_i = i;
			
			_mc.coins_txt.text = data.coins;
			_mc.price_txt.text = data.price;
			Misc.addSimpleButtonListeners(_mc.buy_btn);
			_mc.buy_btn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
                dispatchEvent(new RequestEvent(RequestEvent.IMREADY)); } );
			_mc.buy_btn.bg.text_txt.text = Lingvo.dictionary.buy();
		}		
		
		public function get i():int 
		{
			return _i;
		}
	}
}