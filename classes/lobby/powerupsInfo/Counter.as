package lobby.powerupsInfo
{
	import events.RequestEvent;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public class Counter extends MovieClipContainer
	{
		private var infinityMode:Boolean = false;
		
		public function Counter(xx:Number, yy:Number, name:String)
		{
			super(new xcounter(), xx, yy);
			this.name = name; //used when dispatching event. 
			_mc.add_btn.visible = false;
		}
		
		public function setAmount(amount:int):void
		{
			_mc.amount_txt.text = amount;
			
			if (!infinityMode) //add btn ain't swon when not in infinity mode			
			{
				_mc.add_btn.visible = amount == 0;
				if (amount == 0) _mc.add_btn.addEventListener(MouseEvent.CLICK, dispatchInstaBuy);
			}
		}
		
		public function goInfinite():void
		{			
			infinityMode = true;
			_mc.gotoAndStop(2);
		}
		
		public function goNormal():void
		{
			_mc.gotoAndStop(1);
			infinityMode = false;
		}
		
		private function dispatchInstaBuy(e:MouseEvent):void 
		{
			dispatchEvent(new RequestEvent(RequestEvent.BUY_POWERUP, null, true));
		}	
	}
}