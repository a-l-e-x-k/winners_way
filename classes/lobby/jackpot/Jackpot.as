package lobby.jackpot 
{
	import basicPlayerItem.BasicPlayerItem;
	import events.RequestEvent;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import playerio.DatabaseObject;
	import flash.net.navigateToURL;
	import fl.containers.UILoader;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class Jackpot extends MovieClipContainer
	{				
		private var _defeated:Array = [];
		
		public function Jackpot() 
		{
			super(new jackpotmc(), 625.6, 99.5);
			
			if (UserData.winCount != -1 && UserData.winCount < Misc.WINS_TO_UNLOCK_JACKPOT) _mc.tounlock_txt.text = Lingvo.dictionary.getWinMore(Misc.WINS_TO_UNLOCK_JACKPOT - UserData.winCount);
			else 
			{
				_mc.gotoAndStop(2);			
				createDudes();
			}
			
			_mc.logo_txt.text = Lingvo.dictionary.jackpot();
			
			Networking.client.bigDB.load("Jackpot", "jp", saveJackpotSize, Misc.handleError);
			Networking.client.bigDB.loadRange("Jackpot", "lastWinner", null, null, null, 1, loadLastWinner, Misc.handleError);
		}
		
		public function createDudes():void
		{
			_mc.info_btn.addEventListener(MouseEvent.CLICK, showJackpotInfo);			
			
			for (var i:int = 0; i < 8; i++) 
			{					
				var playerItem:BasicPlayerItem = new BasicPlayerItem(); //substitute fake one to real one
				playerItem.mc.x = (_mc.getChildByName("guy_" + i) as MovieClip).x;
				playerItem.mc.y = (_mc.getChildByName("guy_" + i) as MovieClip).y;
				playerItem.name = (_mc.getChildByName("guy_" + i) as MovieClip).name;
				playerItem.mc.score_txt.visible = false;	
				addChild(playerItem);
				
				_mc.removeChild(_mc.getChildByName("guy_" + i));
			}				
			
			var ids:Array = [];
			for (var i:int = 0; i < UserData.streak.length; i++) ids[i] = UserData.streak[i]; //cleans names			
			
			if (ids.length > 0)
			{
				Networking.socialNetworker.eventDispatcher.addEventListener(RequestEvent.AVATARS_LINKS_LOADED, onAvatarLinksLoaded);	
				Networking.socialNetworker.getAvatarLinks(ids);						
			}
		}
		
		private function onAvatarLinksLoaded(e:RequestEvent):void 
		{
			Networking.socialNetworker.eventDispatcher.removeEventListener(RequestEvent.AVATARS_LINKS_LOADED, onAvatarLinksLoaded);
			for (var i:int = 0; i < e.stuff.users.length; i++) 
			{
				(getChildByName("guy_" + i) as BasicPlayerItem).createGuy(e.stuff.users[i].uid, 0xFFFFFF, e.stuff.users[i].photo);
			}
		}
		
		private function loadLastWinner(arr:Array):void 
		{			
			trace("loadLastWinner");
			trace([arr[0].id]);
			var f:Function;
			Networking.socialNetworker.eventDispatcher.addEventListener(RequestEvent.AVATARS_WITH_SEX_LOADED, f = function(e:RequestEvent) 
			{
				onAvatarsWithSexLoaded(arr, e.stuff); 
				Networking.socialNetworker.eventDispatcher.removeEventListener(RequestEvent.AVATARS_WITH_SEX_LOADED, f);
			});
			Networking.socialNetworker.getPhotoAndSexAndName(arr[0].id);			
		}	
		
		private function onAvatarsWithSexLoaded(arr:Array, response:Object):void 
		{
			trace("onAvatarsWithSexLoaded");
			t.obj(response);
			var millisecondsUnix:int = (arr[0].date as Date).time;
			var diff:int = (new Date().time - millisecondsUnix);
			var hours:int = Math.floor(diff / (1000 * 60 * 60));
			var minutes:int = Math.floor((diff - hours * 1000 * 60 * 60) / (1000 * 60));
			
			_mc.loading_anim.visible = false;
			_mc.won_txt.text = response.name + " " + Lingvo.dictionary.getWon(response.sex) + "\n" + arr[0].prize + " " + Lingvo.dictionary.coins() + "\n" + getAgoTime(hours, minutes);
			
			var avatar:UILoader = Networking.getAvatarContainer(response.photo);	
			mc.ava_mc.question_mc.addChild(avatar);
			avatar.addEventListener(MouseEvent.CLICK, function(e:MouseEvent) { navigateToURL(new URLRequest(Networking.socialNetworker.coreLink + arr[0].id), "_blank"); } );
			avatar.buttonMode = true;
			_mc.ava_mc.alpha = _mc.won_txt.alpha = 100;
		}
		
		private function saveJackpotSize(obj:DatabaseObject):void 
		{
			_mc.value_txt.text = obj.value;
		}
		
		private function getAgoTime(hours:int, minutes:int):String 
		{
			var result:String = "";
			if (hours == 0 && minutes == 0) result = Lingvo.dictionary.justnow();
			else result = (hours > 0 ? hours + Lingvo.dictionary.h() + " " : "") + minutes + Lingvo.dictionary.m() + " " + Lingvo.dictionary.ago();
			return result;
		}
		
		private function showJackpotInfo(e:MouseEvent):void 
		{
			dispatchEvent(new RequestEvent(RequestEvent.SHOW_JACKPOT_INFO, null, true));
		}		
	}
}