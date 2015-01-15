package games.gameUI 
{
	import basicPlayerItem.BasicPlayerItem;
	import flash.text.TextField;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class PlayerItem extends BasicPlayerItem
	{					
		private var _textFieldThatMatters:TextField;
		
		public function PlayerItem(usersPicture:Boolean) 
		{		
			super(usersPicture);		
			
			_mc.x = 10;
			_mc.y = 7;
			
			_textFieldThatMatters = usersPicture?mc.score_txt:mc.scoreleft_txt;
			mc.score_txt.alpha = usersPicture?1:0;
			mc.scoreleft_txt.alpha = usersPicture?0:1;
			
			if (!usersPicture) _mc.x = 717;
		}
		
		public function changePoints(value:int):void
		{
			if (int(_textFieldThatMatters.text) + value > 0) _textFieldThatMatters.text = (int(_textFieldThatMatters.text) + value).toString();
			else _textFieldThatMatters.text = "0";
		}
	}
}