package 
{
	import events.RequestEvent;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.getDefinitionByName;
	
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class RSLLoader 
	{
		public static const eventDispatcher:EventDispatcher = new EventDispatcher();
		public static var links:Object;
		
		public static function assignLinks(networkerType:String):void
		{
			if (networkerType == "fb")
			{
				links =
				{
					snake: "https://r.playerio.com/r/winners-way-fb-rl3wvjarykcscflu8gjnxg/Winners Way FB Facebook App/swf/Snake.swf", 
					stackUp: "https://r.playerio.com/r/winners-way-fb-rl3wvjarykcscflu8gjnxg/Winners Way FB Facebook App/swf/StackUp.swf", 
					wordSeekers: "https://r.playerio.com/r/winners-way-fb-rl3wvjarykcscflu8gjnxg/Winners Way FB Facebook App/swf/WordSeekers.swf",
					level1: "https://r.playerio.com/r/winners-way-fb-rl3wvjarykcscflu8gjnxg/Winners Way FB Facebook App/swf/Level%201.swf",
					level2: "https://r.playerio.com/r/winners-way-fb-rl3wvjarykcscflu8gjnxg/Winners Way FB Facebook App/swf/Level%202.swf",
					level3: "https://r.playerio.com/r/winners-way-fb-rl3wvjarykcscflu8gjnxg/Winners Way FB Facebook App/swf/Level%203.swf",
					level4: "https://r.playerio.com/r/winners-way-fb-rl3wvjarykcscflu8gjnxg/Winners Way FB Facebook App/swf/Level%204.swf",
					level5: "https://r.playerio.com/r/winners-way-fb-rl3wvjarykcscflu8gjnxg/Winners Way FB Facebook App/swf/Level%205.swf",
					level6: "https://r.playerio.com/r/winners-way-fb-rl3wvjarykcscflu8gjnxg/Winners Way FB Facebook App/swf/Level%206.swf",
					level7: "https://r.playerio.com/r/winners-way-fb-rl3wvjarykcscflu8gjnxg/Winners Way FB Facebook App/swf/Level%207.swf",
					level8: "https://r.playerio.com/r/winners-way-fb-rl3wvjarykcscflu8gjnxg/Winners Way FB Facebook App/swf/Level%208.swf",
					level9: "https://r.playerio.com/r/winners-way-fb-rl3wvjarykcscflu8gjnxg/Winners Way FB Facebook App/swf/Level%209.swf",
					level10: "https://r.playerio.com/r/winners-way-fb-rl3wvjarykcscflu8gjnxg/Winners Way FB Facebook App/swf/Level%2010.swf",
					snakeTutorial: "https://r.playerio.com/r/winners-way-fb-rl3wvjarykcscflu8gjnxg/Winners Way FB Facebook App/swf/Snake%20Tutorial.swf",
					stackUpTutorial: "https://r.playerio.com/r/winners-way-fb-rl3wvjarykcscflu8gjnxg/Winners Way FB Facebook App/swf/StackUp%20Tutorial.swf"
				}
			}
			else if (networkerType == "local")
			{
				links =
				{
					snake: "Snake/Snake.swf", 
					stackUp: "StackUp/StackUp.swf", 
					wordSeekers: "WordSeekers/WordSeekers.swf",
					level1: "Story/Level 1.swf",
					level2: "Story/Level 2.swf",
					level3: "Story/Level 3.swf",
					level4: "Story/Level 4.swf",
					level5: "Story/Level 5.swf",
					level6: "Story/Level 6.swf",
					level7: "Story/Level 7.swf",
					level8: "Story/Level 8.swf",
					level9: "Story/Level 9.swf",
					level10: "Story/Level 10.swf",
					snakeTutorial: "Tutorials/Snake Tutorial.swf",
					stackUpTutorial: "Tutorials/StackUp Tutorial.swf"
				}
			}
			else if (networkerType == "vk")
			{
				links =
				{
					snake: "http://cs10766.vk.com/u73920149/9d23a854e266c4.zip", 
					stackUp: "http://cs10766.vk.com/u73920149/287a5ec055629f.zip", 
					wordSeekers: "http://cs10766.vk.com/u73920149/d54dd0376352b1.zip",
					level1: "http://cs10766.vk.com/u73920149/eca7b3becc906f.zip",
					level2: "http://cs10766.vk.com/u73920149/52bbef7b1eef20.zip",
					level3: "http://cs10766.vk.com/u73920149/f2c0928260ae9e.zip",
					level4: "http://cs10766.vk.com/u73920149/7fc73a57b781a1.zip",
					level5: "http://cs10766.vk.com/u73920149/96ec0b3e4d3b2a.zip",
					level6: "http://cs10766.vk.com/u73920149/fb8e7bd154fe17.zip",
					level7: "http://cs10766.vk.com/u73920149/21b0075a161e81.zip",
					level8: "http://cs10766.vk.com/u73920149/b73ebf033dc9b4.zip",
					level9: "http://cs10766.vk.com/u73920149/22f2498424ac1c.zip",
					level10: "http://cs10766.vk.com/u73920149/aa25b29fb87cc2.zip",
					snakeTutorial: "http://cs10766.vk.com/u73920149/b7bc507148536c.zip",
					stackUpTutorial: "http://cs10766.vk.com/u73920149/c4c6bca9c834fa.zip",
					logo: "http://cs10766.vk.com/u73920149/e42bc0a4bb4f21.zip",
					invite: "http://cs10766.vk.com/u73920149/4f86f85c4d989c.zip"			
				}
			}
		}
		
		public static function tryLoad(name:String):void
		{
            trace("RSL Try load: " + name);
			if (!(rslExists(name)))
			{
				var context:LoaderContext = new LoaderContext();
				context.applicationDomain = ApplicationDomain.currentDomain;
				var loader:Loader = new Loader();		// load in the asset swf
				loader.name = name;//so at loadComplete handler it would be possible to find out what was loaded & dispatch corresponding event
				var req:URLRequest = new URLRequest(links[name]);
				
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
				try
				{
					loader.load(req, context);						
				}
				catch (e:Error)
				{
					if (Networking.client != null)
                        Networking.client.errorLog.writeError("Asset load error", e.message + e.name, e.getStackTrace(), null);
				}
			}			
			else
			{
				if (name.indexOf("level") != -1) eventDispatcher.dispatchEvent(new RequestEvent(RequestEvent.LOADED_LEVEL_MC));
				else if (name == Misc.STACK_UP_GAME || name == Misc.WORD_SEEKERS_GAME || name == Misc.SNAKE_GAME) eventDispatcher.dispatchEvent(new RequestEvent(RequestEvent.LOADED_GAME_RSL));
				else if (name == "snakeTutorial") eventDispatcher.dispatchEvent(new RequestEvent(RequestEvent.LOADED_SNAKE_TUTORIAL));
				else if (name == "stackUpTutorial") eventDispatcher.dispatchEvent(new RequestEvent(RequestEvent.LOADED_STACK_UP_TUTORIAL));			
				else if (name == "logo") eventDispatcher.dispatchEvent(new RequestEvent(RequestEvent.LOADED_LOGO));
				else if (name == "invite") eventDispatcher.dispatchEvent(new RequestEvent(RequestEvent.LOADED_INVITE));
			}							
		}
		
		public static function rslExists(name:String):Boolean 
		{
			var exists:Boolean = true;
			try
			{
                var someClass:Class;
				if (name == Misc.WORD_SEEKERS_GAME) someClass = getDefinitionByName("field") as Class;
				else if (name == Misc.SNAKE_GAME) someClass = getDefinitionByName("agava") as Class;
				else if (name == Misc.STACK_UP_GAME) someClass = getDefinitionByName("shapesBox") as Class;
				else if (name == "invite") someClass = getDefinitionByName("hambatikol") as Class;
				else if (name == "logo") someClass = getDefinitionByName("logotypic") as Class;
				else if (name.indexOf("level") != -1) someClass = getDefinitionByName(name) as Class; //level mcs 1-10
				else if (name == "snakeTutorial") someClass = getDefinitionByName("eatfru") as Class; //level mcs 1-10
				else if (name == "stackUpTutorial") someClass = getDefinitionByName("dontfall") as Class;
                trace(someClass);
			}
			catch (e:Error) //means game assets were already loaded. No need 2 ask 4 them
			{
				exists = false;
			}
			return exists;
		}
		
		private static function onLoadComplete(e:Event):void 
		{
			trace("RSL loaded. bytesTotal: " + e.currentTarget.bytesTotal);
			trace("RSL loaded. loader.name: " + e.currentTarget.loader.name);
			if (e.currentTarget.loader.name.indexOf("level") != -1) eventDispatcher.dispatchEvent(new RequestEvent(RequestEvent.LOADED_LEVEL_MC));
			else if (e.currentTarget.loader.name == Misc.STACK_UP_GAME || e.currentTarget.loader.name == Misc.WORD_SEEKERS_GAME || e.currentTarget.loader.name == Misc.SNAKE_GAME) eventDispatcher.dispatchEvent(new RequestEvent(RequestEvent.LOADED_GAME_RSL));
			else if (e.currentTarget.loader.name == "snakeTutorial") eventDispatcher.dispatchEvent(new RequestEvent(RequestEvent.LOADED_SNAKE_TUTORIAL));
			else if (e.currentTarget.loader.name == "stackUpTutorial") eventDispatcher.dispatchEvent(new RequestEvent(RequestEvent.LOADED_STACK_UP_TUTORIAL));			
			else if (e.currentTarget.loader.name == "logo") eventDispatcher.dispatchEvent(new RequestEvent(RequestEvent.LOADED_LOGO));
			else if (e.currentTarget.loader.name == "invite") eventDispatcher.dispatchEvent(new RequestEvent(RequestEvent.LOADED_INVITE));
		}
	}

}