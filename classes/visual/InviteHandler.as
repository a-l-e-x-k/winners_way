package visual 
{
	import events.RequestEvent;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.net.navigateToURL;
	import flash.net.URLRequest;
	import flash.utils.getDefinitionByName;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public class InviteHandler extends Visual 
	{		
		public function InviteHandler(fromWall:Boolean) 
		{
			super();
			
			if (fromWall) //app launched from invite at VK wall
			{
				RSLLoader.eventDispatcher.addEventListener(RequestEvent.LOADED_INVITE, onInviteLoaded);
				RSLLoader.tryLoad("invite");
			}
		}
		
		private function onInviteLoaded(e:RequestEvent):void 
		{
			var assetClass:Class = getDefinitionByName("hambatikol") as Class;
			var inviteMC:MovieClip = new assetClass(); //it's already of stage size & made to be put at (0,0) coordinates
			inviteMC.play_btn.addEventListener(MouseEvent.CLICK, gotoFullPage);
			inviteMC.play_btn.addEventListener(MouseEvent.ROLL_OVER, onOver);
			inviteMC.play_btn.addEventListener(MouseEvent.ROLL_OUT, onOut);
			inviteMC.play_btn.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			inviteMC.play_btn.text_txt.text = Lingvo.dictionary.play();
			addChild(inviteMC);
		}
		
		private function onDown(e:MouseEvent):void {e.currentTarget.gotoAndStop("down"); }		
		private function onOut(e:MouseEvent):void {	e.currentTarget.gotoAndPlay("up"); }		
		private function onOver(e:MouseEvent):void {if (e.currentTarget.currentFrameLabel != "down") e.currentTarget.gotoAndStop("over"); }		
		private function gotoFullPage(e:MouseEvent):void {navigateToURL(new URLRequest("http://vk.com/winnersway"), "_blank"); }		
	}
}