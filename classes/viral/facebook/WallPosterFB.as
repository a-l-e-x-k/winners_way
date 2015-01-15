package viral.facebook 
{
	import com.facebook.graph.Facebook;
	import events.RequestEvent;
	import flash.display.Bitmap;
	import flash.events.EventDispatcher;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class WallPosterFB 
	{
		public static var targetID:String = "";
		public static var image:Bitmap;
		public static var message:String = "";
		public static var eventDispatcher:EventDispatcher = new EventDispatcher();
		
		public static function wallPicturePost(targetid:String, picture:Bitmap, messagestr:String):void
		{
			//targetID = targetid;
			//image = picture;				
			//message = messagestr;
			
			//TODO: do things
		}		
		
		public static function doSimplePost(mess:String):void
		{
			trace("doSimplePost");
			message = mess;
			if (UserData.permissions.publish_stream) doPost();
		}	
		
		public static function doPost():void 
		{
			trace("doPost");
			var values:Object = {};
			values.picture = "https://fbcdn-photos-a.akamaihd.net/photos-ak-snc1/v85006/173/206405252767397/app_1_206405252767397_2188.gif";
			values.link = "https://www.facebook.com/arcade.battles";
			values.caption = message;
			Facebook.api("/" + UserData.id + "/feed", onPostPosted, values, "POST");
		}
		
		private static function onPostPosted(result:Object, fail:Object):void 
		{
			trace("onPostPosted");
			t.obj(result);
			t.obj(fail);
			eventDispatcher.dispatchEvent(new RequestEvent(RequestEvent.IMREADY));
		}		
		
	}

}