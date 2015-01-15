package popups.finishPopup 
{
    import basicPlayerItem.BasicPlayerItem;

    import events.RequestEvent;

    import flash.display.Bitmap;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.utils.getDefinitionByName;

    import lobby.myWay.StreakBar;

    import caurina.transitions.Tweener;

    /**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class StoryPreview extends Sprite
	{
		public var _levelMC:MovieClip;
		private var _levelMC2:MovieClip;
		private var _levelMC2ID:int;
		private var _levelMC2Forward:Boolean = false;
		private var _currentLevelGuys:Array; //array of guys pictures at level
		private var _streakBar:StreakBar = new StreakBar();
		
		public function StoryPreview() 
		{
			trace(" StoryManager.currentLevel : " +  StoryManager.currentLevel);
			var assetClass:Class = getDefinitionByName("level" + StoryManager.currentLevel) as Class;
			_levelMC = new assetClass(); 
			addChild(_levelMC);

            var levelLabel:String = "guy" + StoryManager.story[StoryManager.currentLevel].length.toString();
            _levelMC.gotoAndStop(levelLabel); //goto guy that will be filled (get ready)

            _currentLevelGuys = StoryManager.createDudes(_levelMC, StoryManager.currentLevel);

			_streakBar.x = 105;
			_streakBar.y = 333;
			addChild(_streakBar); //it's just empty Sprite now
		}

		public function showDraw():void
		{
			tryAddSecondPicture();
			_streakBar.tryShowDraw(); //if at streak, it'll just show streak bar
		}
		
		private function tryAddSecondPicture(loss:Boolean = false):void 
		{
			var toCompare:int = loss ? 4 : 3;
			if ((StoryManager.getLevelLength(StoryManager.currentLevel) - StoryManager.story[StoryManager.currentLevel].length) < toCompare)
			{
				_levelMC2ID = StoryManager.currentLevel + 1;
				trace("adding fuute, pat");
				_levelMC2Forward = true;
				addSecondLevelPicture();
			}
			else if (StoryManager.currentLevel > 1 && (StoryManager.story[StoryManager.currentLevel].length == 0))
			{
				_levelMC2ID = StoryManager.currentLevel - 1;
				trace("adding prev, pat");
				addSecondLevelPicture();
			}		
		}
		
		public function showWin(loserMC:BasicPlayerItem, loserID:String):void
		{			
			var newLevel:Boolean = StoryManager.addGuy(loserID);  //WARNING! Works only for 2-people game					
			trace("newLevel: " + newLevel);	
			
			var targetGuyNumber:int = newLevel?StoryManager.getLevelLength(StoryManager.currentLevel - 1) - 1:StoryManager.story[StoryManager.currentLevel].length - 1; //number of guy at level (e.g. 0, 1, 2... 7)			
			trace("guy id: " + targetGuyNumber);
			
			_streakBar.tryShowWin();			
			
			var mcOfFinPop:MovieClip = this.parent as MovieClip; //container_mc
			
			trace("_currentLevelGuys[targetGuyNumber].mc.x: " + _currentLevelGuys[targetGuyNumber].mc.x);
			trace("_currentLevelGuys[targetGuyNumber].mc.y: " + _currentLevelGuys[targetGuyNumber].mc.y);
			
			Tweener.addTween(loserMC.mc, { x:_currentLevelGuys[targetGuyNumber].mc.x + _levelMC.mc.x + mcOfFinPop.x, time:2, delay:1, transition:"easeOutExpo" }); //this.parent.parent - _mc property of FinishPopup
			Tweener.addTween(loserMC.mc, { y:_currentLevelGuys[targetGuyNumber].mc.y + _levelMC.mc.y + mcOfFinPop.y, time:2, delay:1, transition:"easeOutExpo", onComplete:function():void
			{
				_levelMC.mc.addChild(loserMC.mc); //can't add before Tween because "story window" is under mask
				loserMC.mc.x -= (_levelMC.mc.x + mcOfFinPop.x);
				loserMC.mc.y -= (_levelMC.mc.y + mcOfFinPop.y);
				trace("calculated x: " + loserMC.mc.x);
				trace("calculated y: " + loserMC.mc.y);
				_levelMC.play();
				_levelMC.addEventListener(Event.ENTER_FRAME, tryCreateNewStreakBar);
				
				if (StoryManager.currentLevel == 2 && StoryManager.story[StoryManager.currentLevel].length == 2 && !UserData.openedStreak) dispatchEvent(new RequestEvent(RequestEvent.SHOW_STREAK_TUTORIAL));//show streak tutorial					
			}});				
			
			Tweener.addTween(loserMC.mc.mc.mc.border_mc.color2_mc, { alpha:100, time:1, delay:1, transition:"easeOutExpo" } );					
			Tweener.addTween(loserMC.mc.mc.mc.border_mc.color_mc, { alpha:0, time:1, delay:1, transition:"easeOutExpo" } );		
			Tweener.addTween(loserMC.mc, { rotation:_currentLevelGuys[targetGuyNumber].mc.rotation, time:1, delay:1, transition:"easeOutExpo" } );	
			loserMC.mc.mc.mc.border_mc.color2_mc.transform.colorTransform = _currentLevelGuys[targetGuyNumber].mc.mc.mc.border_mc.color_mc.transform.colorTransform;
			
			if ((StoryManager.getLevelLength(StoryManager.currentLevel) - StoryManager.story[StoryManager.currentLevel].length) < 2 || newLevel) //if level is full (filled the last guy)
			{
				trace("adding future guy. level: " + StoryManager.currentLevel);
				_levelMC2ID = StoryManager.currentLevel + (newLevel?0:1);
				_levelMC2Forward = true;
				addSecondLevelPicture();
			}
			else if (StoryManager.currentLevel > 1 && StoryManager.story[StoryManager.currentLevel].length == 1) //1st guy at level
			{
				_levelMC2ID = StoryManager.currentLevel - 1;
				addSecondLevelPicture();
			}
			
			trace("fading guy out");
			Tweener.addTween(_currentLevelGuys[targetGuyNumber], { alpha:0, time:1, delay:1, transition:"easeOutExpo", onComplete:function():void //fade-out fake guy item that is being substituted
			{
				trace("removing dude");
				_levelMC.mc.removeChild(_currentLevelGuys[targetGuyNumber]); //remove fake picture
			}});					
		}
		
		private function tryCreateNewStreakBar(e:Event):void 
		{
			if (e.currentTarget.currentFrameLabel != null) 
			{
				_streakBar.tryShowStreakAfterSingleGuy(); //frame labels like "guy0", "guy1". 
				e.currentTarget.removeEventListener(Event.ENTER_FRAME, tryCreateNewStreakBar);
			}
		}
		
		public function showLoss():void
		{
			tryAddSecondPicture(true);
			trace("_levelMC.currentFrameLabel: " + _levelMC.currentFrameLabel);
			var passedGuyIndex:int = int(_levelMC.currentFrameLabel.substr(3, _levelMC.currentFrameLabel.length - 3));
			if (StoryManager.getStreakStartIndexes(StoryManager.currentLevel).indexOf(passedGuyIndex) == -1) //if guy is not the streak starter, show rollback-animation
			{
				_levelMC.gotoAndStop(_levelMC.currentFrame - 1);
				addEventListener(Event.ENTER_FRAME, goBackwards);
			}
			_streakBar.tryShowLoss();
		}
		
		public function optimise():void
		{
			bitmapise(_levelMC);
		}
		
		private static function bitmapise(levelMC:MovieClip):void //substitutes graphics_mc for bitmap of it.
		{
			var levelSnapshot:Bitmap = Misc.snapshot(levelMC.mc.graphics_mc, StoryManager.currentLevel == 3 ? levelMC.mc.graphics_mc.width:StoryManager.STORY_WIDTH, StoryManager.currentLevel == 3 ? levelMC.mc.graphics_mc.height:StoryManager.STORY_HEIGHT, true);
			levelSnapshot.name = "graphics_bmp";
			levelMC.mc.removeChild(levelMC.mc.graphics_mc);
			levelMC.mc.addChildAt(levelSnapshot, 0);
		}
		
		private function addSecondLevelPicture():void
		{
			trace("adding 2nd level picture. _levelMC2ID: " + _levelMC2ID);
			var assetClass:Class = getDefinitionByName("level" + _levelMC2ID.toString()) as Class;
			_levelMC2 = new assetClass();
			bitmapise(_levelMC2);
			
			if ((_levelMC2Forward && (_levelMC2ID == 2 || _levelMC2ID == 8)) || (!_levelMC2Forward && _levelMC2ID == 4)) //filled 1st or 7th level, adding new level at the right side of prev one
			{
				_levelMC2.mc.x = StoryManager.STORY_WIDTH; //_levelMC.mc.x + 
			}							
			else if (_levelMC2Forward && (_levelMC2ID == 3 || _levelMC2ID == 4 || _levelMC2ID == 6 || _levelMC2ID == 7 || _levelMC2ID == 9 || _levelMC2ID == 10)) //adding new level at the "up" side of prev one
			{
				_levelMC2.mc.y = -StoryManager.STORY_HEIGHT;			//_levelMC.mc.y - 	
			}	
			else if ((_levelMC2Forward && _levelMC2ID == 5) || (!_levelMC2Forward && (_levelMC2ID == 1 || _levelMC2ID == 7))) //adding new level at the left side of prev one
			{
				_levelMC2.mc.x = -StoryManager.STORY_WIDTH; // _levelMC.mc.x - 
			}	
			else if (!_levelMC2Forward && (_levelMC2ID == 2 || _levelMC2ID == 3 || _levelMC2ID == 5 || _levelMC2ID == 6 || _levelMC2ID == 8 || _levelMC2ID == 9)) //adding old level at down
			{
				_levelMC2.mc.y = StoryManager.STORY_HEIGHT; // _levelMC.mc.y +
			}
			
			_levelMC.mc.addChildAt(_levelMC2, 0); 			
			StoryManager.createDudes(_levelMC2, _levelMC2ID);
		}
		
		private function goBackwards(e:Event):void 
		{
			if (_levelMC.currentFrameLabel != null)
			{
				var passedGuyIndex:int = int(_levelMC.currentFrameLabel.substr(3, _levelMC.currentFrameLabel.length - 3));
				trace("passed guy #" + passedGuyIndex);
				removeGuy(passedGuyIndex);
				
				if (StoryManager.getStreakStartIndexes(StoryManager.currentLevel).indexOf(passedGuyIndex) != -1)
				{
					trace("guy is the streak starter. stopping");
					removeEventListener(Event.ENTER_FRAME, goBackwards);
					return;
				}
			}
			_levelMC.gotoAndStop(_levelMC.currentFrame - 1);
		}	
		
		private function removeGuy(passedGuyIndex:int):void 
		{
			_currentLevelGuys[passedGuyIndex].mc.mc.mc.pic_mc.question_mc.visible = true;
			Tweener.addTween(_currentLevelGuys[passedGuyIndex].mc.mc.mc.pic_mc.getChildByName("uiloader"), { alpha:0, time:2, transition:"easeInSine" });
		}
		
		public function clean():void
		{
			(_levelMC.mc.getChildByName("graphics_bmp") as Bitmap).bitmapData.dispose();
			if (_levelMC2 != null) (_levelMC2.mc.getChildByName("graphics_bmp") as Bitmap).bitmapData.dispose();
		}
	}
}