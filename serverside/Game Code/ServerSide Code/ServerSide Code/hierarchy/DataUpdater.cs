using System;
using System.Collections;
using System.Collections.Generic;
using PlayerIO.GameLibrary;

namespace ServerSide
{
	public abstract class DataUpdater : NewbieManager
	{
		public Player Creator;		
		protected Dictionary<string, Player> Guys = new Dictionary<string, Player>(); //to store all Players. Players INumerable will remove guys after they disconnect. This thing will not		
		protected bool SpiralSaved = true;
		protected bool StorySaved = true;		
		private int _winnerLevel;

		protected void UpdateStoriesAndSpiral(string winnerId, string loserID, bool isFirstInStreak)
		{
		    if (!(Guys[loserID].IsDummy))
		    {
		        UpdateLosersStory(loserID);
		    }
			if (!(Guys[winnerId].IsDummy))
			{
				_winnerLevel = UpdateWinnersStory(winnerId, loserID); //winnerLvl is only used for updating top. 
				UpdateSpiral(winnerId, loserID, isFirstInStreak);
			}
			else
			{
				StorySaved = true;
				SpiralSaved = true;
			}
		}

		private void UpdateLosersStory(string loserID)
		{
			if (!Guys.ContainsKey(loserID)) throw new PlayerIOError(ErrorCode.UnknownIndex, "loserID does not exist in guys dict");

			var losersStory = Guys[loserID].PlayerObject.GetArray("story");
			var currentLevel = GetCurrentLevel(losersStory);

		    var databaseArray = losersStory[currentLevel] as DatabaseArray;
		    if (databaseArray != null)
		    {
		        var startIndices = Data.LevelStreakStartIndexes(currentLevel);
		        for (var k = databaseArray.Count - 1; k > -1; k--) //find last streak start
		        {
		            if (!databaseArray.Contains(k)) //fix for "Array does not have entry at: 3"
		            {
                        var streakStarter = startIndices.Contains(k);
		                databaseArray.Set(k, "73920149" + (streakStarter ? "-f" : ""));
		            }

		            var s = databaseArray[k] as String;
		            if (s == null || !s.Contains("-f"))
		                continue;

		            var toRemoveCount = databaseArray.Count - k - 1;
		            Console.WriteLine("toRemoveCount:" + toRemoveCount);
		            for (var y = 0; y < toRemoveCount; y++) //remove all items in streak
		            {
		                if (databaseArray.Contains(databaseArray.Count - 1)) databaseArray.RemoveAt(databaseArray.Count - 1);
		            }
		            break;
		        }
		    }
		    Guys[loserID].PlayerObject.Save();
		}

		private int UpdateWinnersStory(string winnerId, string loserId)
		{
			var winnersStory = Guys[winnerId].PlayerObject.GetArray("story");
			var clean = new ArrayList(); //without "_f" suffixes. Used 4 existsAlready test
			var currentLevel = GetCurrentLevel(winnersStory);
			for (var j = 1; j < winnersStory.Count; j++) //copy all the story without "-f"s to clean array (for further exists-check)
			{
				for (var m = 0; m < (winnersStory[j] as DatabaseArray).Count; m++)
				{
				    if (!(winnersStory[j] as DatabaseArray).Contains(m)) //fix for "Array does not have entry at: 3"
					{
						var streakStarter = Data.LevelStreakStartIndexes(currentLevel).Contains(m);
						(winnersStory[j] as DatabaseArray).Set(m, "73920149" + (streakStarter ? "-f" : ""));
					}

				    clean.Add((winnersStory[j] as DatabaseArray).GetString(m).Contains("-f")
				        ? (winnersStory[j] as DatabaseArray)[m].ToString()
				            .Substring(0, (winnersStory[j] as DatabaseArray)[m].ToString().Length - 2)
				        : (winnersStory[j] as DatabaseArray)[m]);
				}
			}

			for (var i = 0; i < (winnersStory[currentLevel] as DatabaseArray).Count; i++)
			{
				Console.WriteLine("guy at level " + currentLevel + ": " + (winnersStory[currentLevel] as DatabaseArray)[i]);
			}

			if (!clean.Contains(loserId)) //only unique guys in story
			{
				if ((winnersStory[currentLevel] as DatabaseArray).Count == 0 || Data.LevelStreakStartIndexes(currentLevel).Contains((winnersStory[currentLevel] as DatabaseArray).Count))
				{
					loserId += "-f"; //If inserting at the start of the streak (or 1st item at level), add "-f" to losers id. (or just no-streak item)
				}
				(winnersStory[currentLevel] as DatabaseArray).Add(loserId);
			}

			if (Guys[winnerId].PlayerObject.Contains("winCount")) //used to lock spiral & jackpot. After that just for stats
			{
				Guys[winnerId].PlayerObject.Set("winCount", Guys[winnerId].PlayerObject.GetInt("winCount") + 1);
			}

			Guys[winnerId].PlayerObject.Save();
			StorySaved = true;
			return currentLevel;
		}

		private void UpdateSpiral(string winnerId, string loserID, bool isFirstInStreak) //updates spiral from FullStories
		{
			PlayerIO.BigDB.LoadOrCreate("FullStories", winnerId, delegate(DatabaseObject dbObj)
			{
				var currentSpiral = dbObj.Contains("a") ? dbObj.GetArray("a") : new DatabaseArray();
				var clean = new List<string>(); //without "_f" suffixes. Used 4 existsAlready test

				foreach (var t in currentSpiral)
				{
				    if (t.ToString().Contains("-f")) clean.Add(t.ToString().Substring(0, t.ToString().Length - 2));
				    else clean.Add(t.ToString());
				}

			    var existsAlready = false;
				foreach (var str in clean)
				{
				    if (str == loserID) 
                        existsAlready = true;
				}
			    if (!existsAlready)
				{
					Console.WriteLine("isFirstInStreak: " + isFirstInStreak);
					if (isFirstInStreak) loserID += "-f";
					currentSpiral.Add(loserID);
					Console.WriteLine("loserId: " + loserID);
				}
				if (!dbObj.Contains("a")) dbObj.Set("a", currentSpiral);
				dbObj.Save();

				var spiralEntriesCount = currentSpiral.Count;
				TryUpdateLikesTop(winnerId, spiralEntriesCount);
				SpiralSaved = true;
			}, HandleError);
		}

		private void TryUpdateLikesTop(string winnerId, int spiralEntriesCount) //if guy is in top-update his lvl there
		{
			PlayerIO.BigDB.Load("Top", "e", delegate(DatabaseObject topCount) //check for being inda TOP100
			{
			    if (topCount.GetInt("v") > spiralEntriesCount) 
                    return;
			    Console.WriteLine("guy may be inda top: " + winnerId);
			    PlayerIO.BigDB.Load("Top", "g", dbObj => TryRearrangeTop(topCount, dbObj, spiralEntriesCount, winnerId));
			});
		}

		private void TryRearrangeTop(DatabaseObject topCount, DatabaseObject topObj, int spiralLength, string winnerId)
		{
			var top = topObj.GetArray("g");
			var alreadyInTheTopIndex = -1;
			for (var k = 0; k < top.Count; k++)
			{
			    var databaseObject = top[k] as DatabaseObject;
			    if (databaseObject != null && databaseObject.GetValue("id").ToString() != winnerId) 
                    continue;
			    alreadyInTheTopIndex = k;
			    break;
			}

			if (topCount.GetInt("v") < spiralLength) //if new likes count is bigger then number of likes of guy #100 in LikesTop100
			{
				var insertIndex = 98;
			    top.RemoveAt(alreadyInTheTopIndex > -1 ? alreadyInTheTopIndex : 99);

			    for (var j = insertIndex; j > -1; j--)
			    {
			        if (((DatabaseObject)top[j]).GetInt("c") >= spiralLength) break; //found the guy with bigger likes count
			        insertIndex = j;
			    }

			    var winnerLevel = GetCurrentLevel(Guys[winnerId].PlayerObject.GetArray("story"));
				Console.WriteLine("winnerLevel: " + winnerLevel);

				var newEntry = new DatabaseObject();
				newEntry.Set("id", winnerId);
				newEntry.Set("c", spiralLength);
				newEntry.Set("lvl", winnerLevel);
				top.Insert(insertIndex, newEntry);
				topObj.Save(); //save with updated top

				topCount.Set("v", top.GetObject(99).GetInt("c")); //update entry threshold
				topCount.Save();
			}
			else if (alreadyInTheTopIndex != -1)//just update winner's level
			{
			    var databaseObject = top[alreadyInTheTopIndex] as DatabaseObject;
			    if (databaseObject != null)
			        databaseObject.Set("lvl", _winnerLevel);
			    topObj.Save();
			}
		}

		protected void ClearStreak(Player player)
		{
			Console.WriteLine("clearStreak for: " + player.ConnectUserId);
			player.PlayerObject.Set("streak", new DatabaseArray());
			player.PlayerObject.Save();
		}

		public void RemoveTutorialProperty(string propertyName, Player player)
		{
			player.PlayerObject.Remove(propertyName);
			player.PlayerObject.Save();
		}

		protected void RemoveTriedOtherGamesProperty(Message message, Player player)
		{
			PlayerIO.BigDB.Load("Statistics", "triedGames", delegate(DatabaseObject obj)
			{
			    switch (message.GetInt(0))
			    {
			        case 0:
			            obj.Set("withoutTut", obj.GetInt("withoutTut") + 1);
			            break;
			        case 1:
			            obj.Set("forcedSucc", obj.GetInt("forcedSucc") + 1);
			            break;
			        case 2:
			            obj.Set("forcedChanged", obj.GetInt("forcedChanged") + 1);
			            break;
			    }
			    obj.Save();
			});

			RemoveTutorialProperty(message.Type, player);
		}

		protected void TryIncreaseJackpot()
		{
			if (Rand.Next(3) == 0)  //each 3rd game increase jackpot 
			{
				PlayerIO.BigDB.Load("Jackpot", "jp", delegate(DatabaseObject dbObj) //update jackpot
				{
					dbObj.Set("value", dbObj.GetUInt("value") + 10); //increment amount of powerups at stake (1 pwrp each game goes into jackpot)
					dbObj.Save();
				});
			}			
		}

		public void SaveRecordedSnakeGame(int fruitScenario, ArrayList recordedTurns, int startPosition)
		{						
			if (recordedTurns.Count > 20)
			{
				PlayerIO.BigDB.Load("SnakeGames", "count", delegate(DatabaseObject savedGamesCount)
				{	
						PlayerIO.BigDB.LoadOrCreate("SnakeGames", (savedGamesCount.GetInt("value") + 1).ToString(), delegate(DatabaseObject obj) //and i don't care that sometimes already created object will be overriden
						{
							var dbturns = GetDatabaseArrayAsArrayListFullCopy(recordedTurns);

							obj.Set("uid", Creator.ConnectUserId);
							obj.Set("scenario", fruitScenario);
							obj.Set("turnsArray", dbturns);
							obj.Set("startPosition", startPosition);
							obj.Save();

							savedGamesCount.Set("value", savedGamesCount.GetInt("value") + 1); //increment only when game inserted
							savedGamesCount.Save();
						}, HandleError);
				});
			}
		}

		public void SaveRecordedWordSeekersGame(int scenarioNumber, ArrayList openedWords)
		{
			if (openedWords.Count > 2)
			{
				PlayerIO.BigDB.Load("WordSeekersGames", "count", delegate(DatabaseObject savedGamesCount)
				{	
					PlayerIO.BigDB.LoadOrCreate("WordSeekersGames", (savedGamesCount.GetInt("value") + 1).ToString(), delegate(DatabaseObject obj) //and i don't care that sometimes already created object will be overriden
					{
						var wordsArr = GetDatabaseArrayAsArrayListFullCopy(openedWords);

						obj.Set("uid", Creator.ConnectUserId);
						obj.Set("scenario", scenarioNumber);
						obj.Set("openedWords", wordsArr);
						obj.Save();

						savedGamesCount.Set("value", savedGamesCount.GetInt("value") + 1); //increment only when game inserted
						savedGamesCount.Save();
					}, HandleError);
				});
			}			
		}

		private DatabaseArray GetDatabaseArrayAsArrayListFullCopy(ArrayList arr)
		{
			var newArr = new DatabaseArray();
			for (var i = 0; i < arr.Count; i++)
			{
				var newObj = new DatabaseObject(); //copy object here. Anti-circular reference
				var toCopy = arr[i] as DatabaseObject;
				foreach (var property in toCopy.Properties)
				{
					if (toCopy[property] is string) newObj.Set(property, (string)toCopy[property]);
					else if (toCopy[property] is int) newObj.Set(property, (int)toCopy[property]);
					else if (toCopy[property] is uint) newObj.Set(property, (uint)toCopy[property]);
					else PlayerIO.ErrorLog.WriteError("Trying to copy DatabaseObject value to unknown type");
				}
				newArr.Set(i, newObj);
			}
			return newArr;
		}

		protected int GetCurrentLevel(DatabaseArray story)
		{
			var level = 1;
			for (var i = 2; i < 10; i++) //max level is 10
			{
				if ((story[i - 1] as DatabaseArray).Count == Data.LevelLength[i - 1]) level = i; //if last level was completed set current level to i 
			}
			return level;
		}
	}
}
