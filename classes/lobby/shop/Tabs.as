package lobby.shop 
{
	import events.RequestEvent;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public class Tabs extends MovieClipContainer
	{
		private var _currentGame:String = "";
		private var _tabs:Array = [];
		
		public function Tabs(currentGame:String) 
		{
			super(new shopTabs(), -273, -188);			
			_currentGame = currentGame;
			addListeners();
		}
		
		protected function addListeners():void 
		{			
			_tabs.push(_mc.snake);
			_tabs.push(_mc.stackUp);
			_tabs.push(_mc.wordSeekers);
			
			for each (var tab:MovieClip in _tabs) 
			{
				tab.addEventListener(MouseEvent.ROLL_OVER, onOver);
				tab.addEventListener(MouseEvent.ROLL_OUT, onOut);
				tab.addEventListener(MouseEvent.MOUSE_DOWN, switchTab);
				
				if (tab.name == _currentGame) 
				{
					tab.gotoAndStop(3);
					tab.buttonMode = false;
				}
			}
		}
		
		private function onOut(e:MouseEvent):void 
		{
			if (e.currentTarget.currentFrame != 3) e.currentTarget.gotoAndStop(1);
		}
		
		private function onOver(e:MouseEvent):void 
		{
			if (e.currentTarget.currentFrame != 3 && e.currentTarget.currentFrame != 2) 
			{
				e.currentTarget.gotoAndStop(2);
				if (e.currentTarget.name == Misc.SNAKE_GAME && e.currentTarget.bg.head_mc.currentFrame == 1) e.currentTarget.bg.head_mc.gotoAndPlay(1);
				else if (e.currentTarget.name == Misc.STACK_UP_GAME && e.currentTarget.bg.star_mc.currentFrame == 1) e.currentTarget.bg.star_mc.gotoAndPlay(1);	
				else if (e.currentTarget.name == Misc.WORD_SEEKERS_GAME && e.currentTarget.bg.currentFrame == 1) e.currentTarget.bg.gotoAndPlay(1);					
			}
		}
		
		private function switchTab(e:MouseEvent):void 
		{			
			for each (var tab:MovieClip in _tabs)
			{
				tab.gotoAndStop(1);
				tab.buttonMode = true;
			}
			_currentGame = e.currentTarget.name;
			e.currentTarget.gotoAndStop(3);
			e.currentTarget.buttonMode = false;
			dispatchEvent(new RequestEvent(RequestEvent.SWITCH_TAB, { name:e.currentTarget.name } ));
		}		
		
		public function get currentGame():String {return _currentGame;}
	}
}