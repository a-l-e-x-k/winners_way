using System;
using PlayerIO.GameLibrary;

namespace ServerSide
{	
	/*
	 * Handles roomType change, does checks for connected user.
	 */
	public abstract class RoomManager : AsyncFunctional
	{
		protected bool NoSwitchGame = false;
		protected int PlayerNumber = 0;

		public override bool AllowUserJoin(Player player) //forbidding connection from the same user id
		{
			var allow = true;
			foreach (var pl in Players)
			{
				if (pl.ConnectUserId == player.ConnectUserId) 
                    allow = false;
			}
			//TODO: if false => send "hey, close another tab"
			return allow;
		}

		public override void UserJoined(Player player)
		{
			PlayerNumber++;
			if (PlayerNumber <= Data.CAPACITY)
			{				
				Console.WriteLine("UserJoined");
				if (player.ConnectUserId == RoomId)  //RoomID is ID of guy in social network. 
				{
					Creator = player;
					CheckForGiveaway(player); //If it's creator of a room & it's 1st join at a day -> do giveaway check, likes, etc
				}
				else
				{
					AddToGuys(player, false); //2nd dude joined. Adding only in not a friendly mode. In friendly adding only after "addMe" message
				}
			}
			else
			{
				player.Send("rc");
				player.Disconnect();
			}			
			//if (player.ConnectUserId == "73920149" || player.ConnectUserId == "1308033905") create100FruitScenarios(); //just uncomment to update scenarios. NB! Previous game will make no sense after that. 
			//if (player.ConnectUserId == "73920149") create100WordsScenarios(); //just uncomment to update scenarios. NB! Previous game will make no sense after that.
			/*if (player.ConnectUserId == "73920149")
			{
					DatabaseObject g = new DatabaseObject();
					DatabaseArray arr = new DatabaseArray();

					for (int j = 0; j < 100; j++)
					{
						DatabaseObject newEntry = new DatabaseObject();
						newEntry.Set("id", "0");
						newEntry.Set("c", 0);
						newEntry.Set("lvl", 0);
						arr.Add(newEntry);
					}

					g.Set("g", arr);
					PlayerIO.BigDB.CreateObject("Top", "g", g, null);
			}*/
		}

		private void CheckForGiveaway(Player player)
		{
			CheckIfNewbie(player);
			var lastDay = player.PlayerObject.GetInt("lastDay");
			var nowDay = DateTime.UtcNow.Day;
			if (lastDay != nowDay) CreditPowerups(player, lastDay);
			if (!(player.PlayerObject.Contains("seenPopup"))) player.PlayerObject.Set("seenPopup", false); //new property, wasnt at playObject by default
			player.PlayerObject.Set("lastDay", nowDay);
			player.PlayerObject.Save();	
		}

		protected void CheckForMarch(Player player)
		{
			var bonusEnds = new DateTime(2012, 3, 10, 20, 0, 0);
			//Console.WriteLine("bonus ends ms: " + (bonusEnds.Subtract(new DateTime(1970, 1, 1, 0, 0, 0))).TotalSeconds.ToString());
			var now = DateTime.UtcNow;
			var timeLeft = bonusEnds.Subtract(now);
			if (timeLeft.TotalSeconds >= 0 && !(player.PlayerObject.Contains("march"))) Give33Powerups(player);
			//Console.WriteLine("Time left: h: " + timeLeft.TotalHours + " m: " + timeLeft.TotalMinutes + " s: " + timeLeft.TotalSeconds);
		}

		protected void ChangeGameType(string gameType)
		{
		    if (NoSwitchGame) return;
		    Console.WriteLine("gameType changed to: {0}", gameType);
		    RoomData["game"] = gameType;
		    RoomData.Save();
		}

		protected abstract void AddToGuys(Player player, bool adminAsUser);
		public override void GameStarted() { }
		public override void UserLeft(Player player) { }
		public override void GameClosed() { }
		public override void GotMessage(Player player, Message message) { }
	}
}
