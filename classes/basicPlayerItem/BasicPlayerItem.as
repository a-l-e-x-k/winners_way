package basicPlayerItem 
{
    import fl.containers.UILoader;

    import flash.display.Bitmap;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.net.URLRequest;
    import flash.net.navigateToURL;

    /**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	
	public class BasicPlayerItem extends BasicPlayerItemBg
	{		
		protected var _color:uint;
		protected var _usersPicture:Boolean;
		
		public function BasicPlayerItem(usersPicture:Boolean = false) 
		{			
			_usersPicture = usersPicture;
            mc.score_txt.alpha = mc.scoreleft_txt.alpha = 0;
            mc.mc.mc.blicks_mc.alpha = 0;
		}

		public function createGuy(uid:String = "", color:uint = 0xFFFFFF, avatarURL:String = null):void
		{
			this.name = uid;
			mc.score_txt.text = "0";
			Misc.applyColorTransform(mc.mc.mc.border_mc.color_mc, color);
			_color = color;	
			
			var cleanLoader:UILoader = Networking.getAvatarContainer(avatarURL);
			cleanLoader.name = "uiloader";
			mc.mc.mc.pic_mc.addChild(cleanLoader);
			
			if (uid != null && uid != "empty")
			{
				mc.mc.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
					trace("navigateto: " + uid);
					navigateToURL(new URLRequest(Networking.socialNetworker.coreLink + uid), "_blank"); } );
				mc.mc.buttonMode = true;
			}
			
			this.addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event):void
			{
				if ((mc.mc.mc.pic_mc.getChildByName("uiloader") as UILoader).getChildByName("pic") != null) 
				{
					((mc.mc.mc.pic_mc.getChildByName("uiloader") as UILoader).getChildByName("pic") as Bitmap).bitmapData.dispose(); //clear memory from avatar
				}
			});			
		}
		
		public function createLevelPicture(levelNumber:int):void
		{
			var picture:Sprite = Misc.getLevelPicture(levelNumber);			
			picture.x = 44 - picture.width / 2;
			picture.y = 44 - picture.height / 2;
			mc.mc.addChild(picture);
		}
		
		public function get color():uint	{	return _color;}		
		public function set color(value:uint):void 
		{
			_color = value;
			Misc.applyColorTransform(mc.mc.mc.border_mc.color_mc, value);				
		}			
	}
}