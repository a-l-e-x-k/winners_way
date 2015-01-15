package popups 
{
    import flash.events.MouseEvent;

    import caurina.transitions.Tweener;

    /**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public class BeggingPopup extends MovieClipContainer
	{
		
		public function BeggingPopup() 
		{
			super(new begpop(), 37, 343);
			_mc.text_txt.text = Lingvo.dictionary.encourageInviting();
			_mc.help_btn.help_txt.text = Lingvo.dictionary.helpInvite();
			Misc.addSimpleButtonListeners(_mc.help_btn);
			_mc.close_btn.nohelp_txt.text = Lingvo.dictionary.wontHelpInvite();
			_mc.help_btn.addEventListener(MouseEvent.CLICK, showInviteDialog);
			_mc.close_btn.addEventListener(MouseEvent.CLICK, removePopup);
			_mc.close_btn.buttonMode = true;
			_mc.help_btn.buttonMode = true;
			Tweener.addTween(this, { y:178, time:0.9, transition:"easeOutCubic" } );
		}
		
		private function showInviteDialog(e:MouseEvent):void 
		{
			Networking.trySend("seenPopup", "ok");
			Networking.socialNetworker.showSocialInvitePopup();
			Tweener.addTween(_mc, { alpha:0, time:0.6, transition:"easeOutSine", onComplete:function():void { removeChild(_mc); } } );
		}				
		
		private function removePopup(e:MouseEvent):void 
		{
			Networking.trySend("seenPopup", "fu");
			Tweener.addTween(_mc, { alpha:0, time:0.6, transition:"easeOutSine", onComplete:function():void { removeChild(_mc); } } );
		}			
	}

}