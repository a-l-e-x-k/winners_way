using System;
using System.Collections;
using System.Globalization;
using PlayerIO.GameLibrary;

namespace ServerSide
{
	/*
	 * Handles giveaway logic. 
	 */
	public abstract class GiveawayManager : StatisticsManager
	{
		private readonly ArrayList _possibleItems = new ArrayList { "boost2x", "50coins", "boost3x", "275coins", "10coins", "sevenMines", "100coins", "grid", "250coins", "missile", "975coins", "firstLetter", "75coins", "removeLetters", "10coins", "swapShape", "25coins", "nanoShape", "150coins", "undo", "175coins", "flyingbar", "100coins" }; //all possible things to giveaway. In order. 

		protected void SetNextGiveaway(Player player)
		{
			var additionSpinners = player.PlayerObject.GetInt("visitsStreak") < 3 ? player.PlayerObject.GetInt("visitsStreak") : 3; //max - five additional spinners
			var nextGiveaway = "";
			for (var i = 0; i < 2 + additionSpinners; i++)
			{
				nextGiveaway += GetRandomGiveawayItem() + (i < (1 + additionSpinners) ? "," : ""); //powerups of any kind. 
			}
			player.PlayerObject.Set("nga", nextGiveaway); //so user can read nga from client
		}

		protected string GetRandomGiveawayItem()
		{
			//40% of the time user receives powerup (avg price = 16 coins), 60% - coins (avg amount = 182.9). => Avg. giveaway per spinner = 116.14 coins (7.25 powerups)
			string result;
			if (Rand.Next(100) < 60) //coin amount
			{
				int[] possibleAmounts = { 50, 275, 10, 100, 250, 975, 75, 10, 25, 150, 175, 100 };
				var amount = possibleAmounts[Rand.Next(possibleAmounts.Length)];
				result = _possibleItems.IndexOf(amount + "coins").ToString(CultureInfo.InvariantCulture);
			}
			else //giveaway powerup
			{
				string[] possiblePowerups = { "boost2x", "boost3x", "sevenMines", "grid", "missile", "firstLetter", "removeLetters", "swapShape", "nanoShape", "undo", "flyingbar" };
				var powerup = possiblePowerups[Rand.Next(possiblePowerups.Length)];
				result = _possibleItems.IndexOf(powerup).ToString(CultureInfo.InvariantCulture);
			}
			Console.WriteLine("result: " + result);
			return result;
		}

		protected void CreditPowerups(Player player, int lastDay)
		{
			if (DateTime.UtcNow.AddDays(-1).Day == lastDay) player.PlayerObject.Set("visitsStreak", player.PlayerObject.GetInt("visitsStreak") + 1); //if guy visited yesterday increase visitsStreak 				
			else player.PlayerObject.Set("visitsStreak", 0); //if guy visited later than yesterday set streak to zero

			var spinnersCount = 1 + (player.PlayerObject.GetInt("visitsStreak") > 0 ? (player.PlayerObject.GetInt("visitsStreak") < 6 ? player.PlayerObject.GetInt("visitsStreak") : 5) - 1 : 0);

			var nga = player.PlayerObject.GetString("nga");
			var splitted = nga.Split(',');

			Console.WriteLine(spinnersCount);

			uint coinsToCredit = 0;
			var powerupsCount = 0;

		    var finalPowerupsCount = 0;
			for (var j = 0; j < spinnersCount; j++) 
            {
                if (_possibleItems[Convert.ToInt32(splitted[j])].ToString().IndexOf("coins", StringComparison.Ordinal) == -1) 
                    finalPowerupsCount++; //thus no empty items will be left at the end of array
            }
			var bi = new BuyItemInfo[finalPowerupsCount];


			for (var j = 0; j < spinnersCount; j++) //go through powerups
			{
			    var itemName = _possibleItems[Convert.ToInt32(splitted[j])].ToString();
			    if (itemName.IndexOf("coins", StringComparison.Ordinal) != -1) //item represents coins ammount
				{
					coinsToCredit += Convert.ToUInt16(itemName.Substring(0, itemName.Length - 5)); //itemName.Length - 5 = "coins"
					Console.WriteLine("coinsToCredit: " + coinsToCredit);
				}
				else
				{
					bi[powerupsCount] = new BuyItemInfo(itemName); //can't use bi.length. Size is fixed at initialisation
					Console.WriteLine("giving away: " + itemName);
					powerupsCount++;
				}
			}

		    player.PayVault.Refresh(() => player.PayVault.Give(bi, delegate { }, HandleError));
			if (coinsToCredit > 0) player.PayVault.Credit(coinsToCredit, "daily giveaway", delegate { });

			SetNextGiveaway(player);
		}

		protected void Give33Powerups(Player player)
		{
			var bi = new BuyItemInfo[33];
			var counter = 0;
			for (var i = 0; i < 3; i++)
			{
				foreach (var t in Data.PowerupNames)
				{
				    bi[counter] = new BuyItemInfo(t);
				    counter++;
				}			
			}

			player.PayVault.Refresh(delegate
			{
				player.PayVault.Give(bi, delegate { }, HandleError);
				player.PlayerObject.Set("bonus8m", true);
				player.PlayerObject.Save();
			});			
		}
	}
}
