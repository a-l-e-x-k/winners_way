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
	public final class PhotoUploaderFB 
	{		
		public static var image:Bitmap;		
		public static var aid:int = -1;
		public static var message:String = "";
		public static var eventDispatcher:EventDispatcher = new EventDispatcher();
		
		public static function addPhotoToAlbum(photo:Bitmap, opponentName:String):void
		{
			image = photo;
			message = Lingvo.dictionary.mygamewith() + " " + opponentName + " " + Lingvo.dictionary.inwinnersway() + ". https://apps.facebook.com/winnersway";	
			if (!UserData.permissions.publish_stream) askForPermissions();
			else uploadPhoto();
		}	
		
		private static function askForPermissions():void //to simulate user click
		{
			Facebook.login(onPermissionsShown, { scope:"publish_stream" } );
		}
		
		private static function onPermissionsShown(result:Object, fail:Object):void 
		{
			trace("onPermsShown");
			t.obj(result);
			if (!(result.expireDate)) eventDispatcher.dispatchEvent(new RequestEvent(RequestEvent.ERROR)); //user denied permission request
			else eventDispatcher.dispatchEvent(new RequestEvent(RequestEvent.PERMISSIONS_GRANTED));
			updatePermissions();
		}
		
		public static function updatePermissions():void
		{
			Facebook.api("/" + UserData.id + "/permissions", onPermissionsLoaded);
		}
		
		private static function onPermissionsLoaded(result:Object, fail:Object):void 
		{
			t.obj(result);
			UserData.permissions = result[0];
		}		
		
		private static function uploadPhoto():void 
		{
			trace("addPhotoToAlbum");
			var values:Object = { message:message, source:image, fileName:'FILE_NAME' }; //, file:photo, image:photo
			Facebook.api("/" + UserData.id + "/photos", onPhotoUploaded, values, "POST");
		}
		
		private static function onPhotoUploaded(result:Object, fail:Object):void 
		{
			trace("onPhotoUploaded");
			t.obj(result);
			t.obj(fail);
			eventDispatcher.dispatchEvent(new RequestEvent(RequestEvent.IMREADY));
		}		
	}
}