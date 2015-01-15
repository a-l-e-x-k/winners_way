package
{
    import com.demonsters.debugger.MonsterDebugger;

    import flash.display.MovieClip;
	import flash.events.Event;
	import flash.system.Security;
	import playerio.Client;
	import playerio.PlayerIO;
	import visual.InviteHandler;
	/**
	* ...
	* @author Alexey Kuznetsov
	*/
    [SWF(width="774", height="630", backgroundColor="#DCE2EE", frameRate="32")]
	public final class Main extends MovieClip
	{
		public static var _visual:InviteHandler;		
		
		public function Main()		
		{
			Security.allowInsecureDomain("*"); 
			Security.allowDomain("*");

            MonsterDebugger.initialize(this);
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onAddedToStage(e:Event):void
		{				
			Networking.parseFlashvars(stage.loaderInfo.parameters);			
			
			_visual = new InviteHandler(Networking.fromWall); //will hold lobby/game
			_visual.name = "visual";
			addChild(_visual);
			
			if (!Networking.fromWall) PlayerIO.connect(stage, Networking.socialNetworker.GAME_ID, "public", UserData.id, "", null, saveClient, Misc.handleError); //fromWall => at VK. When app is being launched at wall (invite)
		}
		
		private static function saveClient(client:Client):void
		{
			trace("saving client");
			Networking.saveClient(client);
			Networking.loadPlayerObject(_visual);
		}	
	}	
}
