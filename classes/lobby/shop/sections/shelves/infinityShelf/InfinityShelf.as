package lobby.shop.sections.shelves.infinityShelf 
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public class InfinityShelf extends Sprite
	{	
		public function InfinityShelf() 
		{
			var mcs:Array = [new ticket1(), new ticket3(), new ticket7(), new ticket30()];			
			for (var i:int = 0; i < 4; i++)
			{
				var offer:InfinityTicket = new InfinityTicket(mcs[i], i, PowerupsManager.getTicketInfo(i));
				addChild(offer);
			}
		}		
	}
}