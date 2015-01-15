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
	import vk.events.CustomEvent;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class PhotoUploaderVK
	{
		public static var eventDispatcher:EventDispatcher = new EventDispatcher();
		public static var image:Bitmap;		
		public static var aid:int = -1;
		public static var message:String = "";
		
		public static function addPhotoToAlbum(photo:Bitmap, opponentName:String):void
		{
			image = photo;
			message = Lingvo.dictionary.mygamewith() + " " + opponentName + " " + Lingvo.dictionary.inwinnersway() + ". http://vk.com/winnersway";	
			
			Networking.socialNetworker.VK.api("getUserSettings", { }, function(response:int) //check access rights
			{ 
				trace("access rights: " + (response & 4).toString()) ;
				if (response & 4) requestAlbums();
				else
				{
					Networking.socialNetworker.VK.callMethod("showSettingsBox", 4); //request photos rights
					Networking.socialNetworker.VK.addEventListener("onSettingsChanged", onSettingChanged);	
				}				
			});			
		}
		
		private static function requestAlbums():void
		{
			trace("requesting albums");			
			Networking.socialNetworker.VK.api("photos.getAlbums", { uid:UserData.id }, checkGameAlbumExistence, dispatchError);
		}
		
		private static function checkGameAlbumExistence(response:Object):void 
		{
			t.obj(response);
			
			for (var i:int = 0; i < response.length; i++) 
			{
				if (response[i].title == "Winner&#39;s Way") aid = response[i].aid;
			}
			
			trace("gameAlbumID: " + aid);
			if (aid.toString() == "-1")
			{
				trace("creating album")
				var description:String = 'Скриншоты моих игр из "Winner' + "'s Way" + '"';
				Networking.socialNetworker.VK.api("photos.createAlbum", { title:"Winner's Way", privacy:0, comment_privacy:1, description:description}, getServerAfterAlbumCreate, dispatchError);
			}
			else //game album exists already => load photos in it
			{
				trace("getting server");
				Networking.socialNetworker.VK.api("photos.getUploadServer", {aid:aid}, uploadPhotoToAlbum, dispatchError);
			}
		}
		
		private static function getServerAfterAlbumCreate(response:Object):void 
		{
			aid = response["aid"];
			t.obj(response);
			trace("getServerAfterAlbumCreate");			
			Networking.socialNetworker.VK.api("photos.getUploadServer", {aid:response["aid"]}, uploadPhotoToAlbum, dispatchError);
		}
		
		private static function uploadPhotoToAlbum(data:Object):void 
		{		
			trace("url: " + data [ "upload_url" ]);
			var upload:MultipartURLLoader = new MultipartURLLoader();
			upload.addFile ( new JPGEncoder ( 100 ).encode ( image.bitmapData), "image.jpg", "photo" );				
			upload.addEventListener ( Event.COMPLETE, onVKImageUploadingComplete);				
			upload.addEventListener ( IOErrorEvent.IO_ERROR, onVKImageUloadingError);				
			upload.addEventListener ( SecurityErrorEvent.SECURITY_ERROR, onVKImageUloadingError);				
			upload.load ( data [ "upload_url" ] );		
		}
	
		private static function onSettingChanged(eve:CustomEvent):void 
		{
			Networking.socialNetworker.VK.removeEventListener("onSettingsChanged", onSettingChanged);	
			trace("settings changed to: " + eve.params[0]);
			trace("e.params[0] & 4:" + (eve.params[0] & 4).toString());
			if (eve.params[0] & 4) Networking.socialNetworker.VK.api("photos.getUploadServer", { aid:aid }, uploadPhotoToAlbum, dispatchError); //now it'll save/add photos
			else eventDispatcher.dispatchEvent(new RequestEvent(RequestEvent.ERROR));	
		}
		
		private static function onVKImageUploadingComplete(e:Event):void 
		{
			trace("VKImageUploadingComplete");
			
			var data:Object = JSON.decode ( ( e.currentTarget as MultipartURLLoader ).loader.data );
			t.obj(data);
			
			Networking.socialNetworker.VK.api ( "photos.save", 
			{
				aid: data [ "aid" ],
				server: data [ "server" ],
				photos_list: data [ "photos_list" ],
				hash:data [ "hash" ]
			}, onImageUploaded, dispatchError);
		}		
		
		private static function onImageUploaded(data:Array):void 
		{
			trace("image uploaded");
			Networking.socialNetworker.VK.api("photos.edit", { pid:data[0].pid, caption:message }, dispatchSuccess, dispatchError);		
			
		}
		
		private static function dispatchSuccess(response:Object):void 
		{
			Networking.trySend("vkv", "ph");
			eventDispatcher.dispatchEvent(new RequestEvent(RequestEvent.IMREADY));
		}
		
		private static function onVKImageUloadingError(e:IOErrorEvent):void 
		{
			trace(e.errorID);
			if (Networking.client != null) Networking.client.errorLog.writeError("onVKImageUloadingError", e.errorID.toString(), "", null);
			dispatchError();
		}	
		
		static private function dispatchError(err:Object = null):void 
		{
			t.obj(err);
			if (err != null && Networking.client != null) Networking.client.errorLog.writeError("Error at PhotoUploader", t.obj(err), "", null);
			eventDispatcher.dispatchEvent(new RequestEvent(RequestEvent.ERROR));
		}
	}
}