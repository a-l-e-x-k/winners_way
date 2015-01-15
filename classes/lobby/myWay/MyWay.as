package lobby.myWay 
{
    import com.gskinner.motion.GTween;
    import com.gskinner.motion.easing.Sine;
    import com.gskinner.motion.plugins.MotionBlurPlugin;

    import events.RequestEvent;

    import caurina.transitions.Tweener;

    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.utils.getDefinitionByName;

    import popups.Popup;
    import popups.tutorial.FirstStreak;
    import popups.tutorial.WTFStoryTwo;

    /**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class MyWay extends Popup
	{
		private const BACK_BTN_INITIAL_X:int = -73;
		private const FORWARD_BTN_INITIAL_X:int = 709;
		private const BACK_BTN_TARGET_X:int = 5;
		private const FORWARD_BTN_TARGET_X:int = 629;
		private const SLIDE_LENGTH:Number = 0.5; //2 sec levelchange animation length
		private const SLIDE_TYPE:Function = Sine.easeOut; //easing type for level change animation
		private var _levelShown:int = 0;
		private var _mainMC:MovieClip;
		private var _sideMC:MovieClip;
		private var _transitionFinished:Boolean = true;
		
		public function MyWay(showTutorial:Boolean) 
		{			
			super(new mystory(), 388, 330);			
			
			trace("StoryManager.currentLevel: " + StoryManager.currentLevel);
			trace("StoryManager.story: " + StoryManager.story);
			
			_mc.logo_txt.text = Lingvo.dictionary.mystory();
			_mc.bg_mc.back_btn.bg.text_txt.text = Lingvo.dictionary.forwardlevel();
			_mc.bg_mc.forward_btn.bg.text_txt.text = Lingvo.dictionary.nextlevel();
			
			_levelShown = StoryManager.currentLevel;
			
			_mainMC = createLevelMc(StoryManager.currentLevel, 0, 0);
			_mc.bg_mc.container_mc.addChild(_mainMC);
			
			_mc.bg_mc.back_btn.buttonMode = true;
			_mc.bg_mc.forward_btn.buttonMode = true;
			_mc.bg_mc.back_btn.addEventListener(MouseEvent.CLICK, goBack);
			_mc.bg_mc.forward_btn.addEventListener(MouseEvent.CLICK, goForward);
			if (StoryManager.currentLevel > 1) 
			{
				RSLLoader.tryLoad("level" + (_levelShown - 1));
				Tweener.addTween(_mc.bg_mc.back_btn, { x:BACK_BTN_TARGET_X, time:1, transition:"easeInOutBack" } );	
			}
			
			if (StoryManager.currentLevel == 2 && StoryManager.story[StoryManager.currentLevel].length == 2 && !UserData.openedStreak)
			{
				var streakTutorial:FirstStreak = new FirstStreak(-this.x, -this.y);
				streakTutorial.addEventListener(RequestEvent.REMOVE_ME, function(e:RequestEvent):void {
					UserData.openedStreak = true;
					Networking.trySend("oST"); //will remove property from player object
					removeChild(streakTutorial); } );
				addChild(streakTutorial);
 			}
			
			MotionBlurPlugin.install();	
			MotionBlurPlugin.enabled = true;							
			MotionBlurPlugin.strength = 0.5;
			
			if (showTutorial)
			{
				addEventListener(Event.ADDED_TO_STAGE, createTutorial);
			}
		}
		
		private function createTutorial(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, createTutorial);
			var tutorial:WTFStoryTwo = new WTFStoryTwo();
			tutorial.x = -this.x;
			tutorial.y = -this.y;
			tutorial.addEventListener(RequestEvent.IMREADY, function(e:RequestEvent):void
			{ 
				removeChild(tutorial);
				dispatchable = true; 
			});
			addChild(tutorial);
				
			Networking.trySend("oST"); //opened story
			dispatchable = false; //so user won't close MyWay before tutorial was completed			
		}
		
		private function createLevelMc(levelID:int, xx:Number, yy:Number):MovieClip 
		{
			var assetClass:Class = getDefinitionByName("level" + levelID) as Class;
			var levelMC:MovieClip = new assetClass(); 
			levelMC.cacheAsBitmap = true;		
			levelMC.x = xx - _mc.bg_mc.container_mc.x;
			levelMC.y = yy - _mc.bg_mc.container_mc.y;
			StoryManager.createDudes(levelMC, levelID);			
			return levelMC;
		}
		
		private function goForward(e:MouseEvent):void 
		{
			if (_levelShown < StoryManager.currentLevel && _transitionFinished)
			{
				_levelShown++;
				if (_levelShown == StoryManager.currentLevel) Tweener.addTween(_mc.bg_mc.forward_btn, { x:FORWARD_BTN_INITIAL_X, time:1, transition:"easeOutBack" } );
				if (_mc.bg_mc.back_btn.x != BACK_BTN_TARGET_X) Tweener.addTween(_mc.bg_mc.back_btn, { x:BACK_BTN_TARGET_X, time:1, transition:"easeOutBack" } );		
				
				tryRemoveLevelMC2();				
				if (_levelShown == 2 || _levelShown == 8) //new levelMC from the right side
				{
					_sideMC = createLevelMc(_levelShown, StoryManager.STORY_WIDTH, 0); 
					new GTween(_mc.bg_mc.container_mc, SLIDE_LENGTH, { x:_mc.bg_mc.container_mc.x - StoryManager.STORY_WIDTH }, { ease:SLIDE_TYPE, autoPlay:true, onComplete:onTransitionComplete } );
				}
				else if (_levelShown == 3 || _levelShown == 4 || _levelShown == 6 || _levelShown == 7 || _levelShown == 9 || _levelShown == 10) //from the top
				{
					_sideMC = createLevelMc(_levelShown, 0, -StoryManager.STORY_HEIGHT); 
					new GTween(_mc.bg_mc.container_mc, SLIDE_LENGTH, { y:_mc.bg_mc.container_mc.y + StoryManager.STORY_HEIGHT }, { ease:SLIDE_TYPE, autoPlay:true, onComplete:onTransitionComplete } );
				}
				else if (_levelShown == 5) //left
				{
					_sideMC = createLevelMc(_levelShown, -StoryManager.STORY_WIDTH, 0); 
					new GTween(_mc.bg_mc.container_mc, SLIDE_LENGTH, { x:_mc.bg_mc.container_mc.x + StoryManager.STORY_WIDTH }, { ease:SLIDE_TYPE, autoPlay:true, onComplete:onTransitionComplete } );
				}
				
				_mc.bg_mc.container_mc.addChild(_sideMC);
				_transitionFinished = false;
			}
		}
		
		private function goBack(e:MouseEvent):void 
		{
			if (Misc.definitionExists("level" + (_levelShown - 1)))
			{				
				if (_levelShown - 2 > 0) RSLLoader.tryLoad("level" + (_levelShown - 2));
				if (_levelShown > 1 && _transitionFinished)
				{
					_levelShown--;
					if (_levelShown == 1) Tweener.addTween(_mc.bg_mc.back_btn, { x:BACK_BTN_INITIAL_X, time:1, transition:"easeOutBack" } );
					if (StoryManager.currentLevel > 1 && _mc.bg_mc.forward_btn.x != FORWARD_BTN_TARGET_X) Tweener.addTween(_mc.bg_mc.forward_btn, { x:FORWARD_BTN_TARGET_X, time:1, transition:"easeOutBack" } );	
					
					tryRemoveLevelMC2();					
					if (_levelShown == 4)  //new levelMC from the right side
					{
						_sideMC = createLevelMc(_levelShown, StoryManager.STORY_WIDTH, 0);
						new GTween(_mc.bg_mc.container_mc, SLIDE_LENGTH, { x:_mc.bg_mc.container_mc.x - StoryManager.STORY_WIDTH }, { ease:SLIDE_TYPE, autoPlay:true, onComplete:onTransitionComplete } );
					}
					else if (_levelShown == 2 || _levelShown == 3 || _levelShown == 5 || _levelShown == 6 || _levelShown == 8 || _levelShown == 9) //from the bottom
					{
						_sideMC = createLevelMc(_levelShown, 0, StoryManager.STORY_HEIGHT); 
						new GTween(_mc.bg_mc.container_mc, SLIDE_LENGTH, { y:_mc.bg_mc.container_mc.y - StoryManager.STORY_HEIGHT}, { ease:SLIDE_TYPE, autoPlay:true, onComplete:onTransitionComplete } );
					}
					else if (_levelShown == 1 || _levelShown == 7) //left
					{
						_sideMC = createLevelMc(_levelShown, -StoryManager.STORY_WIDTH, 0); 
						new GTween(_mc.bg_mc.container_mc, SLIDE_LENGTH, { x:_mc.bg_mc.container_mc.x + StoryManager.STORY_WIDTH }, { ease:SLIDE_TYPE, autoPlay:true, onComplete:onTransitionComplete } );
					}
					
					_mc.bg_mc.container_mc.addChild(_sideMC);		
					_transitionFinished = false;
				}
			}
		}
		
		private function onTransitionComplete():void
		{
			_transitionFinished = true;
		}
		
		private function tryRemoveLevelMC2():void //renews levelMC
		{
			if (_sideMC != null)
			{
				_mc.bg_mc.container_mc.removeChild(_mainMC); //remove current (which id side:))
				_mainMC = _sideMC; //make current - side. 
			}			
		}
	}
}