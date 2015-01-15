package viral.vk
{
	import com.adobe.serialization.json.JSON;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import viral.external.JPGEncoder;
	import viral.external.MultipartURLLoader;
	import vk.api.serialization.json.JSON;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class WallAppPosterVK
	{
		public static var eventDispatcher:EventDispatcher = new EventDispatcher();
		public static var targetID:String = "";
		public static var image:Bitmap;
		public static var message:String = "";
		
		public static function wallPicturePost(targetid:String, picture:Bitmap, messagestr:String):void
		{
			targetID = targetid;
			image = picture;
			message = messagestr;
			Networking.socialNetworker.VK.api("wall.getPhotoUploadServer", { }, onPhotoUploaderComplete, dispatchError);
		}
		
		static private function onPhotoUploaderComplete(data:Object):void 
		{			
			trace("url: " + data [ "upload_url" ]);
			trace("image: " + image);
			var upload:MultipartURLLoader = new MultipartURLLoader();
			upload.addFile ( new JPGEncoder ( 100 ).encode ( image.bitmapData), "image.jpg", "photo" );				
			upload.addEventListener ( Event.COMPLETE, onVKImageUploadingComplete);				
			upload.addEventListener ( IOErrorEvent.IO_ERROR, onVKImageUloadingError);				
			upload.addEventListener ( SecurityErrorEvent.SECURITY_ERROR, onVKImageUloadingError);				
			upload.load ( data [ "upload_url" ] );		
		}
		
		static private function onVKImageUploadingComplete(e:Event):void 
		{
			trace("VKImageUploadingComplete");
			
			var data:Object = JSON.decode ( ( e.currentTarget as MultipartURLLoader ).loader.data );
			t.obj(data);
			
			Networking.socialNetworker.VK.api ( "wall.savePost", 
			{
				wall_id:targetID,
				message:message,
				server:data [ "server" ],
				photo:data [ "photo" ],
				hash:data [ "hash" ]
			}, onSavePostComplete, dispatchError);
		}		
		
		static private function onSavePostComplete(data:Object):void 
		{
			Networking.socialNetworker.VK.callMethod ( "saveWallPost", data [ "post_hash" ] );
			Networking.trySend("vkv", "inv");
		}
		
		static private function onVKImageUloadingError(e:IOErrorEvent):void 
		{
			trace(e.errorID);
			if (Networking.client != null) Networking.client.errorLog.writeError("VKImageUloadingError: ", e.errorID.toString(), e.text, null);
		}	
		
		static private function dispatchError(response:Object):void 
		{
			t.obj(response);
			if (Networking.client != null) Networking.client.errorLog.writeError("VKImageUloadingError: ", t.obj(response), "", null);
		}
	}

}