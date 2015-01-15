package lobby.shop.sections.shelves.infinityShelf 
{
	import events.RequestEvent;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public class InfinityTicket extends MovieClipContainer
	{
		
		public function InfinityTicket(ticketPicture:MovieClip, i:int, info:Object) 
		{
			super(new infticket(), 0, 39);
			x = -323 + i * (_mc.width + 18);
			
			_mc.addChild(ticketPicture);
			_mc.name_txt.text = Lingvo.dictionary.getInfinityText(info.duration);
			_mc.price_txt.text = info.price;
			_mc.buy_btn.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
                dispatchEvent(new RequestEvent(RequestEvent.BUY_POWERUP, { index:i, gameName:info.gameName, goodType:"infinity" }, true)); } );
			_mc.buy_btn.buttonMode = true;
			Misc.addSimpleButtonListeners(_mc.buy_btn);
			_mc.buy_btn.bg.text_txt.text = Lingvo.dictionary.buy();
		}		
	}
}