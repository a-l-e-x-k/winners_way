package lobby.userInfo 
{
	import events.RequestEvent;
	import fl.containers.UILoader;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class UserInfo extends MovieClipContainer 
	{		
		private var _avatar:UILoader;
		
		public function UserInfo() 
		{
			super(new userinfo(), 4, 4);
			_mc.cash_txt.text = UserData.coins;
			
			showPhotoName();
			
			var picture:Sprite = Misc.getLevelPicture(StoryManager.currentLevel);			
			picture.x = _mc.user_pic.x + _avatar.width - picture.width / 2 - 5;
			picture.y = _mc.user_pic.y + _avatar.height - picture.height / 2 - 5;
			_mc.addChild(picture);
			
			Networking.socialNetworker.eventDispatcher.addEventListener(RequestEvent.BALANCE_CHANGED, updateTextFields);
		}
		
		public function updateTextFields(e:RequestEvent = null):void
		{
			_mc.cash_txt.text = UserData.coins;
		}
		
		public function showPhotoName():void
		{
            trace("UserData.name: " + UserData.name);
			_avatar = Networking.getAvatarContainer(UserData.photoURL);
			_mc.user_pic.question_mc.addChild(_avatar);
			_mc.name_txt.text = UserData.name;
		}
	}
}