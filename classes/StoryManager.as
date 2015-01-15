package  
{
	import basicPlayerItem.BasicPlayerItem;
	import events.RequestEvent;
	import flash.display.MovieClip;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class StoryManager 
	{
		public static const STORY_WIDTH:int = 705;
		public static const STORY_HEIGHT:int = 465;
		public static var story:Array = []; //array with levels (each lvl is array also)
		public static var currentLevel:int = 1;
		
		public static function calculateMyCurrentLevel():void 
		{
			t.obj(story)			
			currentLevel = calculateCurrentLevel(story);
			loadLevelMcs();
		}
		
		public static function calculateCurrentLevel(storyArray:Array):int
		{
			var level:int = 1;
			for (var i:int = 1; i < storyArray.length; i++) //story.length - 1 - max level is 10, no need 2 make a check at 10th level
			{
				if (storyArray[i].length == getLevelLength(i)) level = i + 1;
			}
			return level;
		}
		
		public static function loadLevelMcs():void
		{
			RSLLoader.tryLoad("level" + currentLevel);
			if(currentLevel > 1) RSLLoader.tryLoad("level" + (currentLevel - 1));
			tryNextLevelLoading();
		}
		
		public static function tryNextLevelLoading():void
		{
			if ((getLevelLength(currentLevel) - story[currentLevel].length) < 4) 
			{
				RSLLoader.tryLoad("level" + (currentLevel + 1)); //next level loaded so at finish popup it could be used
				trace("loading next level");
			}
		}
		
		public static function getLevelLength(levelID:int):int
		{
			var length:int = 1;
			if (levelID == 1) length = 5;
			else if (levelID == 2) length = 6;
			else if (levelID == 3) length = 8;
			else if (levelID == 4) length = 8;
			else if (levelID == 5) length = 10;
			else if (levelID == 6) length = 9;
			else if (levelID == 7) length = 9;
			else if (levelID == 8) length = 8;
			else if (levelID == 9) length = 10;
			else if (levelID == 10) length = 7;
			return length;
		}
		
		public static function getStoryLength():int //returns total amount of guys in story
		{
			var total:int = 0;
			for (var i:int = 1; i < 11; i++) 
			{
				total += getLevelLength(i);
			}
			return total;
		}
		
		public static function getStoryCompletedLength():int //returns total amount of defeated guys in story
		{
			var total:int = 0;
			for (var i:int = 1; i < story.length; i++) 
			{
				total += story[i].length;
			}
			return total;
		}
		
		public static function getStreakStartIndexes(levelID:int):Array
		{
			var indexes:Array = [];
			if (levelID == 1)
			{
				indexes = [0, 1, 2, 3, 4];
			}
			else if (levelID == 2)
			{
				indexes = [0, 1, 2, 4, 5];
			}
			else if (levelID == 3)
			{
				indexes = [0, 1, 3, 4, 7];
			}
			else if (levelID == 4)
			{
				indexes = [0, 2, 4, 5];
			}
			else if (levelID == 5)
			{
				indexes = [0, 2, 5, 6, 9];
			}
			else if (levelID == 6)
			{
				indexes = [0, 3, 4, 8];
			}
			else if (levelID == 7)
			{
				indexes = [0, 3, 4];
			}
			else if (levelID == 8)
			{
				indexes = [0, 2];
			}
			else if (levelID == 9)
			{
				indexes = [0, 4];
			}
			else if (levelID == 10)
			{
				indexes = [0];
			}
			return indexes;
		}
		
		public static function getCurrentStreak():Object //returns streak length & streak completed count.
		{
			var currentIndexAtLevel:int = story[currentLevel].length;
			var currentLevelIndexes:Array = getStreakStartIndexes(currentLevel);
			var streakStartIndex:int = 0;
			var completedCount:int = 0;
			for (var i:int = currentLevelIndexes.length - 1; i > -1; i--) 
			{
				if (currentLevelIndexes[i] == currentIndexAtLevel) //currently at streak start. 0 guys in streak defeated
				{
					streakStartIndex = currentIndexAtLevel;
					break;
				}
				else if (currentLevelIndexes[i] < currentIndexAtLevel) //found streakStart index which is less then currentIndex: some guys in streak are defeated. 
				{
					streakStartIndex = currentLevelIndexes[i];
					completedCount = currentIndexAtLevel - currentLevelIndexes[i];
					break;
				}
			}
			
			var streakLength:int = 0;
			if (currentLevelIndexes.indexOf(streakStartIndex) == currentLevelIndexes.length - 1) //last streak at level
			{
				streakLength = getLevelLength(currentLevel) - streakStartIndex; //last streak at level
			}
			else 
			{
				var nextStreakIndex:int = currentLevelIndexes[currentLevelIndexes.indexOf(streakStartIndex) + 1];
				streakLength = nextStreakIndex - streakStartIndex;
			}
			return { length:streakLength, completedCount:completedCount, startIndex:streakStartIndex };
		}
		
		public static function getPreviousStreak():Object //returns about previous streak
		{
			var prevStreakStartIndex:int;
			var levelIndexes:Array;
			var completedCount:int = 0;
			var streakLength:int = 0;
			
			if (getCurrentStreak().startIndex == 0) //first streak at level. Means previous streak is last streak at prev level. Function is called after adding guy to story, so this code won't execute at 1st lvl
			{
				levelIndexes = getStreakStartIndexes(currentLevel - 1);
				prevStreakStartIndex = levelIndexes[levelIndexes.length - 1];
				completedCount = streakLength = (getLevelLength(currentLevel - 1) - 1) - prevStreakStartIndex;
			}
			else
			{
				levelIndexes = getStreakStartIndexes(currentLevel);
				prevStreakStartIndex = levelIndexes[levelIndexes.indexOf(getCurrentStreak().startIndex) - 1]
				completedCount = streakLength = (getCurrentStreak().startIndex - prevStreakStartIndex);
			}			
			return { length:streakLength, completedCount:completedCount, startIndex:prevStreakStartIndex };
		}
		
		public static function justCompletedBigStreak():Boolean
		{
			var atStreakStart:Boolean = getStreakStartIndexes(currentLevel).indexOf(getCurrentStreak().startIndex) != -1; //if we are now at streak start, then prev streak is completed
			var lastStreakWasBig:Boolean = getPreviousStreak().length > 1;
			return atStreakStart && lastStreakWasBig;
		}
		
		public static function checkExistence(guyId:String):Boolean
		{
			var exists:Boolean = false;
			for (var j:int = 1; j <= currentLevel; j++) 
			{
				for (var i:int = 0; i < story[j].length; i++) 
				{
					if (guyId == getCleanName(story[j][i] as String))
					{
						exists = true;
						break;
					}
				}
			}
			return exists;
		}
		
		public static function addGuy(guyId:String):Boolean
		{
			trace("before adding the guy: " + story[currentLevel]);
			var newLevel:Boolean = false;
			if (story[currentLevel].length == getLevelLength(currentLevel) - 1) //if inserting the last guy in the level -> make a  level-up
			{
				story[currentLevel].push(guyId + (getStreakStartIndexes(currentLevel).indexOf(story[currentLevel].length) != -1 ? "-f" : "")); //first guy at level is always "-f"	
				currentLevel++;
				newLevel = true;
			}
			else
			{
				story[currentLevel].push(guyId + (getStreakStartIndexes(currentLevel).indexOf(story[currentLevel].length) != -1 ? "-f" : ""));			
			}			
			trace("after adding the guy: " + story[currentLevel]);
			return newLevel;
		}
		
		public static function clearStreak():void
		{
			trace("before clearing the streak: " + story[currentLevel]);
			var currentStreakInfo:Object = getCurrentStreak();
			for (var i:int = 0; i < currentStreakInfo.completedCount; i++) //for each guy at current level 
			{
				story[currentLevel].pop();
			}
			trace("cleared streak: " + story[currentLevel]);
		}
		
		public static function getCleanName(name:String):String
		{
			return name.indexOf("-f") == -1?name:name.substr(0, name.length - 2);
		}
		
		public static function coloriseStreak(streakItems:Array):void //streakItems - Array of MSs + their avatarLinks
		{
			for (var i:int = 0; i < streakItems.length; i++) 
			{
				(streakItems[i].item as BasicPlayerItem).createGuy(streakItems[i].item.name, Misc.STREAK_COLORS[streakItems.length - 1], streakItems[i].avatarlink);
			}
		}	
		
		public static function createDudes(levelMC:MovieClip, levelID:int):Array 
		{
			var items:Array = [];
			var fakeMc:MovieClip;
			for (var j:int = 0; j < getLevelLength(levelID); j++) //create all items for the level
			{
				fakeMc = levelMC.mc.getChildByName("guy" + j) as MovieClip;
				var newMC:BasicPlayerItem = new BasicPlayerItem(); //substitute fake one to real one
				newMC.mc.x = fakeMc.x;
				newMC.mc.y = fakeMc.y;
				newMC.mc.rotation = fakeMc.rotation;
				newMC.cacheAsBitmap = true;
				newMC.mc.score_txt.visible = false;
				newMC.name = (story[levelID] != null && ((story[levelID] as Array).length > j)) ? getCleanName(story[levelID][j]) : "empty";  //only if not empty item (defeated guy)
				trace("newMC.name: " + newMC.name);
				items.push(newMC);					
				levelMC.mc.addChild(newMC);
				levelMC.mc.removeChild(fakeMc);
			}
			
			var idsToLoad:Array = [];
			for (var i:int = 0; i < items.length; i++) if (items[i].name.indexOf("empty") == -1) idsToLoad.push(items[i].name);			
			
			if (idsToLoad.length > 0) 
			{
				var f:Function;
				Networking.socialNetworker.eventDispatcher.addEventListener(RequestEvent.AVATARS_LINKS_LOADED, f = function(e:RequestEvent)
				{
					trace("loaded photos of guys at level");
					Networking.socialNetworker.eventDispatcher.removeEventListener(RequestEvent.AVATARS_LINKS_LOADED, f);
					invokeColoriseStreak(levelID, items, idsToLoad, e.stuff.users);
				});
				Networking.socialNetworker.getAvatarLinks(idsToLoad);
			}
			else invokeColoriseStreak(levelID, items, idsToLoad);	//no guys 	
			
			trace("guys created");
			
			return items;
		}
		
		static private function invokeColoriseStreak(levelID:int, mcs:Array, idsToLoad:Array, response:Array = null):void 
		{
			var currentStreak:Array = [];
			
			for (var j:int = 0; j < mcs.length; j++)
			{
				if (getStreakStartIndexes(levelID).indexOf(j) != -1) //if it's a start
				{
					coloriseStreak(currentStreak);	//if first item in the streak but not the first streak
					currentStreak = [];
				}
				
				if (response != null && idsToLoad.indexOf(mcs[j].name) != -1)
				{					
					currentStreak.push( { item:mcs[j], avatarlink:response[idsToLoad.indexOf(mcs[j].name)].photo } );
				}
				else currentStreak.push( { item:mcs[j], avatarlink:null } );
				
				if (j == mcs.length - 1) coloriseStreak(currentStreak);	
			}
		}
	}

}