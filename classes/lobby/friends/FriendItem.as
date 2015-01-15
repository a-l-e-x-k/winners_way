package lobby.friends 
{
    import basicPlayerItem.BasicPlayerItem;

    import flash.events.MouseEvent;

    import playerio.DatabaseObject;

    import caurina.transitions.Tweener;

    /**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class FriendItem extends MovieClipContainer
	{
		private var _picture:BasicPlayerItem;

		public function FriendItem(i:int, name:String, id:String, count:int = -1, level:int = 0, pictureURL:String = "", inApp:Boolean = false) 
		{			
			super(new friendItem(), i * (63 + 5) + 6, 0);
			_mc.name_txt.text = name;
			this.name = id;
			
			_picture = new BasicPlayerItem(); //substitute fake one to real one
			_picture.mc.x = _mc.pic_mc.x;
			_picture.mc.y = _mc.pic_mc.y;
			_picture.name = _mc.pic_mc.name;
			_picture.mc.score_txt.visible = false;
			_picture.mc.mc.mc.border_mc.visible = false;			
			_mc.addChildAt(_picture, _mc.getChildIndex(_mc.place_mc)); //info things on the top of picture
			_mc.removeChild(_mc.getChildByName("pic_mc"));				
			
			if (count > -1)
			{
				_mc.count_txt.text = count.toString();
				_mc.place_mc.mc.place_txt.text = (i + 1).toString();		
				if(level > 0) _picture.createLevelPicture(level);
			}
			else 
			{
				_mc.name_txt.y = 59;
				_mc.count_txt.visible = false;
				_mc.place_mc.visible = false;
				
				if (!inApp) //in non-inApp friend
				{
					_mc.invite_btn.alpha = 100;
					_mc.invite_btn.buttonMode = true;
					_mc.invite_btn.mc.text_txt.htmlText = "<font size=8>" + Lingvo.dictionary.invite() + "</font>";
					_mc.name_txt.visible = false;
					Misc.addSimpleButtonListeners(_mc.invite_btn);
					_mc.invite_btn.addEventListener(MouseEvent.CLICK, showInvitePopup);
				}
				else //inApp friend
				{
					Networking.client.bigDB.load("PlayerObjects", id, getLevel, Misc.handleError);
				}
			}
			
			_picture.createGuy(id, 0xFFFFFF, pictureURL);
		}
		
		private function getLevel(dbObj:DatabaseObject):void //TODO: it's possible to make "Show detailed info" button here for inApp friends since whole PlayerObject is available
		{
			if (dbObj != null) _picture.createLevelPicture(StoryManager.calculateCurrentLevel(dbObj.story)); //dbObj may be null only at dev stage when ids are random
		}
		
		private function showInvitePopup(e:MouseEvent):void 
		{
			Networking.socialNetworker.showFriendInvite(this.name);
			e.currentTarget.removeEventListener(MouseEvent.CLICK, showInvitePopup);
			Tweener.addTween(e.currentTarget, {alpha:0, time:2, transition:"easeOutExpo"});		
		}

		public function get picture():BasicPlayerItem {	return _picture;}		
	}

}