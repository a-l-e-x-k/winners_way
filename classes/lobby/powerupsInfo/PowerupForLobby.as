package lobby.powerupsInfo 
{
	import events.RequestEvent;
	import fl.motion.AnimatorFactory;
	import fl.motion.Motion;
	import fl.motion.MotionBase;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.filters.*;
	import flash.geom.Point;
	import flash.utils.getDefinitionByName;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class PowerupForLobby extends MovieClipContainer
	{
		private var _amount:int = 0;
		private var _counter:Counter;
		
		public function PowerupForLobby(name:String, i:int, j:int, powerupPanelHeight:Number) 
		{		
			super(new itemContainer(), 10, j * powerupPanelHeight + (42 + i * ((new itemContainer()).height + 10)));
			var assetClass:Class = getDefinitionByName(name) as Class;
			var picture:MovieClip = new assetClass();
			_mc.mc.pic_mc.addChild(picture);				
			
			this.name = name;
			
			_counter = new Counter(_mc.width + 5, _mc.height / 2, name);
			addChild(_counter);			
		}
		
		public function goInfinite():void
		{
			_counter.goInfinite();
		}
		
		public function goNormal():void
		{
			_counter.goNormal();
			_counter.setAmount(_amount); //update textfields
		}
		
		public function set amount(amount:int):void
		{
			_amount = amount;
			_counter.setAmount(amount);			
		}
		public function get amount():int {	return _amount;	};		
	}
}