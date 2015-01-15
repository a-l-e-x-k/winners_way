using System;
using PlayerIO.GameLibrary;

namespace ServerSide
{
	/*
	 * Checks if user is 1st time in game. If yes - gives start capital, creates PlayerObject, credits powerups, etc. 
	 */
	public abstract class NewbieManager : GiveawayManager
	{
		protected void CheckIfNewbie(Player player)
		{
		    if (player.PlayerObject.Contains("streak")) return;
		    var streak = new DatabaseArray();
		    var story = new DatabaseArray();
		    //DatabaseArray thirdLVL = new DatabaseArray();
		    //thirdLVL.Set(0, "1012-f");
		    //thirdLVL.Set(1, "101-f");
		    //thirdLVL.Set(2, "1013");
		    //thirdLVL.Set(3, "1014-f");
		    //thirdLVL.Set(4, "1011-f");
		    story.Set(0, new DatabaseArray());
		    for (var t = 1; t < 11; t++)
		    {
					
		        //if (t > 3) 
		        //else if (t == 3) story.Set(t, thirdLVL);
		        //if (t < 10) FillLevel(t, story); //
		        story.Set(t, new DatabaseArray());
		        //if (t == 3) 
		    }

		    player.PlayerObject.Set("streak", streak);
		    player.PlayerObject.Set("story", story);
		    player.PlayerObject.Set("lastDay", DateTime.UtcNow.Day); //TODO: remove it, set now! **set yesterday**
		    player.PlayerObject.Set("visitsStreak", 0);
		    player.PlayerObject.Set("winCount", 0);
		    player.PlayerObject.Set("oJP", false); //opened jackpot (for showing tutorial popup)
		    player.PlayerObject.Set("oSP", false); //opened spiral (for showing tutorial popup)
		    player.PlayerObject.Set("oWS", false); //opened WordSeekers (for showing tutorial popup)
		    player.PlayerObject.Set("oSU", false); //opened stackUp (for showing tutorial popup)
		    player.PlayerObject.Set("oSN", false); //opened snake. Used for detecting newbie
		    player.PlayerObject.Set("oST", false); //opened streak (for showing tutorial popup)
		    player.PlayerObject.Set("tOG", false); //tried other games except Snake
		    player.PlayerObject.Set("oSO", false); //seen tutrorial which is explainnig WTF is the story (which is shown after 1st victory)
		    player.PlayerObject.Save();

		    var fullstoryobject = new DatabaseObject();
		    fullstoryobject.Set("a", new DatabaseArray());
		    PlayerIO.BigDB.CreateObject("FullStories", player.ConnectUserId, fullstoryobject,
		        dbObj => Console.WriteLine("fullstory created"));
		    SetNextGiveaway(player);

		    GiveStartCapital(player);
		}

		private void GiveStartCapital(BasePlayer player)
		{
			Console.WriteLine("givestartcapital");
			player.PayVault.Credit(1000, "starter", () => Console.WriteLine("1000 credited"), HandleError);
			var allItems = new BuyItemInfo[Data.PowerupNames.Length * 3];
			for (var j = 0; j < Data.PowerupNames.Length; j++)
			{
				for (var i = 0; i < 3; i++) //3 items of each kind
				{
					allItems[j * 3 + i] = new BuyItemInfo(Data.PowerupNames[j]); //fill array with "BuyItemInfo"
				}
			}
			player.PayVault.Give(allItems, null, HandleError);
		}

//		private void FillLevel(int levelNumber, DatabaseArray story)
//		{
//			var levelArray = new DatabaseArray();
//		    for (var i = 0; i < Data.levelLength[levelNumber]; i++)
//			{
//			    var end = Data.levelStreakStartIndexes(levelNumber).Contains(i) ? "-f" : "";
//			    levelArray.Set(i, rand.Next(1000) + end);
//			}
//		    story.Set(levelNumber, levelArray);
//		}
	}
}
