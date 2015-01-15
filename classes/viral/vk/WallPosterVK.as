package viral.vk
{
	import com.adobe.serialization.json.JSON;
	import events.RequestEvent;
	import flash.display.Bitmap;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import viral.external.JPGEncoder;
	import viral.external.MultipartURLLoader;
	import vk.api.serialization.json.JSON;
	import vk.events.CustomEvent;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class WallPosterVK
	{
		public static var image:Bitmap;
		public static var message:String = "";
		public static var eventDispatcher:EventDispatcher = new EventDispatcher();
		
		public static function wallPicturePost(picture:Bitmap, userName:String):void
		{
			image = picture;				
			message = Lingvo.dictionary.mygamewith() + " " + userName + " " + Lingvo.dictionary.inwinnersway() + ". http://vk.com/winnersway";
			
			Networking.socialNetworker.VK.api("getUserSettings", { }, function(response:int) //check access rights
			{ 
				trace("access rights: " + (response & 4).toString()) ;
				if (response & 4) getServer();
				else
				{
					Networking.socialNetworker.VK.callMethod("showSettingsBox", 4); //request photos rights
					Networking.socialNetworker.VK.addEventListener("onSettingsChanged", onSettingChanged);		
				}				
			});							
		}
		
		private static function getServer():void
		{
			Networking.socialNetworker.VK.api("photos.getWallUploadServer", { }, onPhotoUploaderComplete, dispatchError);	
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
			
			Networking.socialNetworker.VK.api ( "photos.saveWallPhoto", 
			{
				server:data [ "server" ],
				photo:data [ "photo" ],
				hash:data [ "hash" ]
			}, onPhotoSaved, dispatchError);
		}		
		
		private static function onSettingChanged(e:CustomEvent):void 
		{
			Networking.socialNetworker.VK.removeEventListener("onSettingsChanged", onSettingChanged);
			trace("settings changed to: " + e.params[0]);
			if (e.params[0] & 4) getServer();
			else eventDispatcher.dispatchEvent(new RequestEvent(RequestEvent.IMREADY));	
		}
		
		static private function onPhotoSaved(data:Object):void 
		{
			t.obj(data);		
			trace("id: " + data["id"]);
			Networking.socialNetworker.VK.api("wall.post", { owner_id:UserData.id, message:message, attachments:data[0].id }, onWallPost, dispatchError);
			trace("onPhotoSaved");
			
		}
		
		static private function onWallPost(response:Object):void 
		{
			t.obj(response);
			Networking.trySend("vkv", "wp");
			eventDispatcher.dispatchEvent(new RequestEvent(RequestEvent.IMREADY));	
		}
		
		static private function onVKImageUloadingError(e:IOErrorEvent):void 
		{
			trace(e.errorID);
			dispatchError();
		}	
		
		static private function dispatchError(err:Object = null):void 
		{
			t.obj(err);
			if (err != null && Networking.client != null) Networking.client.errorLog.writeError("WallPoster error: ", t.obj(err), "", null);
			eventDispatcher.dispatchEvent(new RequestEvent(RequestEvent.ERROR));
		}
	}
}