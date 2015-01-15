package lobby.shop.sections.shelves.packsShelf 
{
	import events.RequestEvent;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class Pack extends MovieClipContainer
	{
		public function Pack(mc:MovieClip, i:int, info:Object) 
		{
			super(mc, -321 + i * (200 + 22), 196);
			_mc.bg.powerups_txt.text = Lingvo.dictionary.usilyalok();
			_mc.bg.price_txt.text = info.price;
			_mc.bg.buy_btn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void { dispatchEvent(new RequestEvent(RequestEvent.BUY_POWERUP, { index:i, goodType:"pack" }, true)); } );
			_mc.bg.buy_btn.buttonMode = true;
			_mc.bg.amount_txt.text = info.ofEach * PowerupsManager.POWERUPS.length;
			Misc.addSimpleButtonListeners(_mc.bg.buy_btn);
			_mc.bg.buy_btn.bg.text_txt.text = Lingvo.dictionary.buy();
			_mc.bg.multi_txt.text = "x" + info.ofEach;
		}		
	}
}