package lobby.myWay 
{
    import flash.display.MovieClip;
    import flash.display.Sprite;

    import caurina.transitions.Tweener;

    /**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public class StreakBar extends Sprite
	{
		private var _mc:MovieClip;
		private var _currentStreakLength:int = -1;
		
		public function StreakBar() 
		{
			
		}	
		
		public function tryShowWin():void
		{
			var currentStreakInfo:Object = StoryManager.getCurrentStreak();
			if (currentStreakInfo.length > 1 || StoryManager.justCompletedBigStreak()) //not showing streal bar when defeating single guys in story. After "||" :  case when completed streak of > than 1 dude && new streak is single dude. 
			{
				trace("currentStreakInfo.completedCount: " + currentStreakInfo.completedCount);
				trace("currentStreakInfo.length: " + currentStreakInfo.length);
				if (currentStreakInfo.completedCount == 0) //if it's == 0 then user just opened the streak. If he was at streak before, then we should wait until that streak completed animation finishes - that make alpha tween and show bar
				{					
					var previousStreak:Object = StoryManager.getPreviousStreak();
					trace("previousStreak.length: " + previousStreak.length);
					if (previousStreak.length > 1)
					{
						createMC(previousStreak.length, previousStreak.completedCount - 1); //completedCount - 1 - shows state before
						Tweener.addTween(_mc.bar_mc.color_mc, { x:getColorMCx(previousStreak.length, previousStreak.completedCount), time:2, transition:"easeOutSine", delay:1, onComplete:function():void
						{
							_mc.text_txt.text = Lingvo.dictionary.completedExcl();
							Misc.delayCallback(function():void { Tweener.addTween(_mc, { alpha:0, time:0.7, transition:"easeOutSine" } ); }, 1100);  //allows user to spot, that steak was completed
							if(currentStreakInfo.length > 1) _currentStreakLength = currentStreakInfo.length; //when animation  till "guy_X" will stop new streak bar will be shown
						}});
					}
					else //showing streak bar after defeating single guy & proceeding to streak tryShowStreakAfterSingleGuy() which is called when adding guy animation finishes playing
					{
						_currentStreakLength = currentStreakInfo.length; 
					}
				}
				else 
				{
					createMC(currentStreakInfo.length, currentStreakInfo.completedCount - 1); //completedCount - 1 - shows state before
					Tweener.addTween(_mc.bar_mc.color_mc, { x:getColorMCx(currentStreakInfo.length, currentStreakInfo.completedCount), time:1.5, transition:"easeOutSine", delay:0.5 } );
					setText(currentStreakInfo.length, currentStreakInfo.completedCount);
				}
			}
		}
		
		public function tryShowDraw():void
		{
			var currentStreakInfo:Object = StoryManager.getCurrentStreak();
			if (currentStreakInfo.length > 1)
			{
				createMC(currentStreakInfo.length, currentStreakInfo.completedCount);
			}
		}
		
		public function tryShowLoss():void
		{
			var currentStreakInfo:Object = StoryManager.getCurrentStreak();
			if (currentStreakInfo.length > 1)
			{
				createMC(currentStreakInfo.length, currentStreakInfo.completedCount);
				if (currentStreakInfo.completedCount > 0) //no animation if were 0 guys at streak
				{
					Tweener.addTween(_mc.bar_mc.color_mc, { x:getColorMCx(currentStreakInfo.length, 0), time:1.5, transition:"easeOutSine", delay:0.5 } );					
					setText(currentStreakInfo.length, 0);
				}
			}
		}
		
		public function tryShowStreakAfterSingleGuy():void
		{
			if (_currentStreakLength != -1) createWithEasing(_currentStreakLength);
		}
		
		private function createMC(streakLength:int, completedCount:int):void
		{
			_mc = new streakbar();
			_mc.bar_mc.color_mc.x = getColorMCx(streakLength, completedCount);
			addChild(_mc);
			Misc.applyColorTransform(_mc.bar_mc.color_mc, Misc.STREAK_COLORS[streakLength - 1]);
			
			setText(streakLength, completedCount);
		}
		
		private function setText(streakLength:int, completedCount:int):void
		{
			_mc.text_txt.text = completedCount + " " + Lingvo.dictionary.of() + " " + streakLength;
		}
		
		private function createWithEasing(nextStreakLength:int):void 
		{
			if (_mc != null && contains(_mc)) removeChild(_mc);
			createMC(nextStreakLength, 0);
			_mc.alpha = 0;
			Tweener.addTween(_mc, { alpha:1, time:0.8, transition:"easeOutSine"});
		}
		
		private function getColorMCx(streakLength:int, completedCount:int):Number
		{
			return (completedCount / streakLength) * _mc.bar_mc.color_mc.width;
		}
	}
}