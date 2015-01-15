package lobby.shop.sections.shelves.powerupsShelf 
{
	import events.RequestEvent;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.getDefinitionByName;
	import popups.Popup;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public class PowerupAmountSelector extends Popup
	{
		private var _amount:int = 1;
		private var _goodName:String;
		
		public function PowerupAmountSelector(goodName:String) 
		{
			super(new buyPowerup(), 386, 313);
			_goodName = goodName;
			
			var assetClass:Class = getDefinitionByName(goodName) as Class;
			var picture:Sprite = new assetClass();
			picture.width = picture.height = 60;
			_mc.container_mc.addChild(picture);
			_mc.name_txt.text = Lingvo.dictionary.getPowerupFullName(goodName);
			
			_mc.up_btn.addEventListener(MouseEvent.CLICK, increaseAmount);
			_mc.down_btn.addEventListener(MouseEvent.CLICK, decreaseAmount);
			_mc.amount_txt.addEventListener(Event.CHANGE, onAmountChange);
			
			Misc.addSimpleButtonListeners(_mc.buy_btn);
			_mc.buy_btn.bg.text_txt.text = Lingvo.dictionary.buy();
			_mc.buy_btn.buttonMode = true;
			_mc.up_btn.buttonMode = true;
			_mc.down_btn.buttonMode = true;
			updateTextfields();
		}		
		
		private function onAmountChange(e:Event):void 
		{
			trace("amount: " + _mc.amount_txt.text);
			_amount = int(_mc.amount_txt.text);
			if (_amount > 100) _amount = 100;
			if (_amount < 1) _amount = 1;
			trace("adjusted amount : " + _amount);
			updateTextfields();
		}
		
		private function increaseAmount(e:MouseEvent):void 
		{
			if (_amount < 100)
			{
				_amount += 3;
				updateTextfields();			
			}
		}
		
		private function decreaseAmount(e:MouseEvent):void 
		{
			if (_amount > 1)
			{
				_amount -= 3;
				updateTextfields();
			}
		}
		
		private function updateTextfields():void
		{
			_mc.amount_txt.text = _amount;
			_mc.price_txt.text = PowerupsManager.getPrice(_goodName) * _amount;
		}	
		
		public function get amount():int {	return _amount;	}		
	}
}