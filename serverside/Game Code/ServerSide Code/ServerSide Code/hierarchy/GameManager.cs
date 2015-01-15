using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using PlayerIO.GameLibrary;
using ServerSide.snake;
using ServerSide.stackUp;
using ServerSide.wordSeekers;

namespace ServerSide
{
	/*
	 * Provides before-after game functional. 
	 */
	[RoomType("basic")]
	public class GameManager : RoomManager
	{
		protected const int TotalColors = 5; //(6 colors total). Array of colors - at client
		private Dictionary<string, uint> _powerupUses = new Dictionary<string, uint>();
		private int _readyCount;
		private bool _refreshPlobjectOnGameStart;
		private Game _game;

		protected override void AddToGuys(Player player, bool adminAsUser)
		{
			if (player.PlayerObject != null && player.PlayerObject.GetArray("story") == null) 
                player.RefreshPlayerObject(() => AddToGuys(player, adminAsUser));
			else
			{
				Console.WriteLine("PROCESS JOIN >> creator: " + (player.ConnectUserId == RoomId) + " PlayerCount: " + PlayerCount);

				Guys[player.ConnectUserId] = player;
				Guys[player.ConnectUserId].Create((int)PlayersColors[Guys.Count - 1], player.ConnectUserId == RoomId);

				if (Guys.Count == Data.CAPACITY)
				{
					Visible = false;
					SendUsersInfo();
				}
				else if ((RoomData["game"] == "snake" || RoomData["game"] == "wordSeekers") && player.ConnectUserId == RoomId) //it'll load random game data for snake, create fake dude and call SendUsersInfo
				{
					Visible = false;
					ProcessAddToGuysAsync(adminAsUser);
				}
				else player.Send("fo"); //send "Founding opponent" to creator.
			}
		}

	    private void SendUsersInfo()  //sending out info about who is playing game in game
		{
			var players = "";
			var colors = "";
			var levels = "";
			var counter = 0;

	        foreach (var guy in Guys.Values)
			{
				Console.WriteLine("guy: " + guy.ConnectUserId);
				counter++;
				var end = (counter == Guys.Values.Count ? "" : ",");
				players += guy.ConnectUserId + end;
				colors += guy.Color + end;
				levels += GetCurrentLevel(guy.PlayerObject.GetArray("story")) + end;
			}
			Broadcast("data", players, colors, levels);
		}

		public override void UserLeft(Player player)
		{
			PlayerNumber--;
			if (_game == null) //delete the guy only if game is not started (room is yet visible), otherwise we need his info for gameFinish
			{
					Guys.Remove(player.ConnectUserId);
			}			
		}

		public override void GameStarted()
		{
			PreloadPlayerObjects = true;
			Visible = false;			
			CreateRandomColors();
		}

		public void CreateRandomColors()
		{
		    for (var i = 0; i < Data.CAPACITY; i++) //set colors for dudes
			{
			    int randomColor;
			    do randomColor = Rand.Next(TotalColors);
				while (PlayersColors.Contains(randomColor));
				PlayersColors.Add(randomColor);
			}
		}

		public override void GotMessage(Player player, Message message)
		{
			switch (message.Type)
			{
				case "8m":
					ScheduleCallback(() => CheckForMarch(player), 10000);				
					break;
				case "ready":
					ProcessReadyMessage();
					break;
				case "buypo": 
					BuySinglePowerups(player, message);
					break;
				case "buyin":
					BuyInfinity(player, message);
					break;
				case "buypa": 
					BuyPowerupsPack(player, message);
					break;
				case "wv":
					GetBalance(player, message);
					break;
				case "vkv":
					SaveVKViralData(player.ConnectUserId, message.GetString(0)); //VK virality (stats for wall posts, photo posts, etc)
					break;
				case "vkr":
					SaveVKReferrerData(player.ConnectUserId, message.GetString(0)); //VK referrers (stats for where from users come)
					break;
				case "goVisible":
					GoVisible(player, message.GetBoolean(0));
					break;
				case "gi":
					TryGoInvisible(player);
					break;
				case "oth":
					_refreshPlobjectOnGameStart = true;
					break;
				case "change":
					ChangeGameType(message.GetString(0));
					break;
				case "oJP": case "oSP": case "oST": case "oSN": case "oWS": case "oSU": case "oSO": 
					RemoveTutorialProperty(message.Type, player);
					break;
				case "tOG":
					RemoveTriedOtherGamesProperty(message, player);
					break;
				case "seenPopup":
					SavePopupStatistics(message.GetString(0));
					UpdateSeenPopupProperty(player);
					break;
				case "ch":
			        foreach (var pl in Guys.Values)
			        {
			            if (player.ConnectUserId != pl.ConnectUserId)
			            {
			                pl.Send("ch", player.ConnectUserId, message.GetString(0));
			            } 
			        } //chat message
					break;
				case "mi": case "sm": case "bo2": case "gr": case "bo3": case "sw": case "ns": case "un": case "fb": case "fl": case "rl": //powerups
					CheckPowerupUseability(player, message);
					break;				
				case "nots":
					//sendNotifications(message.GetString(0), player);
					break;
				default:
					if (_game != null) _game.HandleSpecialMessage(player, message);
					break;
			}			
		}

		private void UpdateSeenPopupProperty(Player player)
		{
			if (player.PlayerObject.Contains("seenPopup"))
			{
				player.PlayerObject.Set("seenPopup", true);
				player.PlayerObject.Save();
			}
			else ScheduleCallback(() => UpdateSeenPopupProperty(player), 1000); //playerObject property may not yet be created
		}

		private void ProcessReadyMessage()
		{
			_readyCount++;
			if (_readyCount == Data.CAPACITY || RoomData["game"] == "snake" || RoomData["game"] == "wordSeekers") //if all guys ready. && Visible => anti-double start. Happens when too fast ready messages. Snake is async
			{
				switch (RoomData["game"])
				{
					case ("snake"):
						_game = new SnakeGame(Guys, this);
						break;
					case ("stackUp"):
						_game = new StackUp(Guys, this);
						break;
					case ("wordSeekers"):
						_game = new WordSeekers(Guys, this);
						break;
				}

				foreach (var guy in Guys.Values)
				{
					if (guy.Creator && _refreshPlobjectOnGameStart)
					{
						guy.RefreshPlayerObject(delegate { }); //player played game in another room & player object was changed there. Hence the refresh.
						_refreshPlobjectOnGameStart = false;
					}
					if (!guy.IsDummy) guy.CheckForInfinity();
				}

				UpdateGamesCounter();
				_readyCount = 0;
				NoSwitchGame = false;
			}
		}

		private void GoVisible(Player player, bool adminAsUser)
		{
			Console.WriteLine("goVisible");
			Console.WriteLine("spiralSaved: " + SpiralSaved);
			Console.WriteLine("storySaved: " + StorySaved);
			if (SpiralSaved && StorySaved)
			{
				Console.WriteLine("went visible");
				CleanUp();
                Visible = true;
				AddToGuys(player, adminAsUser);
			}
			else ScheduleCallback(() => GoVisible(player, adminAsUser), 500); //can cleanUp only if spiral was saved. Don't wanna delete guy[] Dictionary...
		}

		private void TryGoInvisible(BasePlayer player)
		{
		    if (PlayerCount != 1) return;
		    Visible = false;
		    CleanUp();
		    player.Send("gio");
		}

		public void FinishGame(string players, string scores, string winnerID = null, string loserID = null) //called by Game when game is finished.
		{
			_game = null; //delete game
			SpiralSaved = false; //it will turn true when updateStory() will be finished. So i make sure that new game won't start while saving is processed.
			StorySaved = false;
			UpdatePowerupStatistics(_powerupUses);
			TryIncreaseJackpot();

		    if (RoomData["game"] == "snake" || RoomData["game"] == "wordSeekers")
		    {
		        SoloFinish(players, scores, winnerID, loserID); //snake is played asyncronously
		    }
		    else
		    {
		        DuoFinish(players, scores, winnerID, loserID); //other games played by 2 guys
		    }
		}

		private void DuoFinish(string players, string scores, string winnerID = null, string loserID = null)
		{
			Console.WriteLine("duoFinish");
			if (winnerID != null)
			{
				var currentStreak = CopyArray(Guys[winnerID].PlayerObject.GetArray("streak"));
				if (DudeAintInStreak(currentStreak, loserID)) currentStreak.Set(currentStreak.Count, loserID); //adding to losers only those players who r not at your streak  ( and not adding yourself:) )				
				Console.WriteLine("currentStreak.Count: " + (currentStreak.Count));

				UpdateStoriesAndSpiral(winnerID, loserID, currentStreak.Count - 1 == 0);

				if (currentStreak.Count > 7) //If "before" + "added now" > streak length needed 2 win -> Streak completed. Give prize
				{
					Console.WriteLine("WON JACKPOT");
					PlayerIO.BigDB.Load("Jackpot", "jp", delegate(DatabaseObject dbObj)
					{
						var cashAmount = dbObj.GetUInt("value"); //amount of powerups
						dbObj.Set("value", (uint)0);
						dbObj.Set("count", dbObj.GetUInt("count") + 1);
						dbObj.Save();

						Guys[winnerID].PayVault.Credit(cashAmount, "won jackpot", null, HandleError);

						var winnerObj = new DatabaseObject();
						winnerObj.Set("id", winnerID);
						winnerObj.Set("prize", cashAmount);
						winnerObj.Set("date", DateTime.UtcNow);
						PlayerIO.BigDB.CreateObject("Jackpot", (dbObj.GetUInt("count")).ToString(CultureInfo.InvariantCulture), winnerObj, delegate { }, HandleError);

						Guys[winnerID].Send("finishjp", players, scores, cashAmount);
						ClearStreak(Guys[winnerID]);
						TryDisconnect(Guys[winnerID]);
					});
				}
				else //else just regular winner saving
				{
					Guys[winnerID].PlayerObject.Set("streak", CopyArray(currentStreak));
					Guys[winnerID].PlayerObject.Save();

					Guys[winnerID].Send("finish", players, scores);
					TryDisconnect(Guys[winnerID]);
				}

			    if (loserID == null) return;
			    ClearStreak(Guys[loserID]);//reset streak, streak in story for losers
                Guys[loserID].Send("finish", players, scores);
                TryDisconnect(Guys[loserID]);
			}
			else //No winner. No changes.
			{
				foreach (var player in Guys.Values) //Send results & disconnect guys
				{
					player.Send("finish", players, scores);
					TryDisconnect(player);
				}
			}		
		}

		public void TryDisconnect(Player guy)
		{
			if (!guy.Creator) guy.Disconnect();  //remove not creator. Don't disconnect if in friendly mode
		}	

		private void CheckPowerupUseability(Player player, Message message) //entirely anti-cheating thing. Client is checking things itself
		{
			player.PayVault.Refresh(delegate
			{				
				var powerup = player.PayVault.First(Data.PowerupNameByMessageType[message.Type]);
			    if (powerup == null && !player.HasInfinity) return;
			    var can = false;									

			    if (!Guys[player.ConnectUserId].PowerupLastUses.ContainsKey(message.Type)) can = true; //if 1st use per game
			    else
			    {
			        if ((DateTime.UtcNow - Guys[player.ConnectUserId].PowerupLastUses[message.Type]).TotalMilliseconds > (Data.PowerupDelay[message.Type] - 500)) can = true; //+500 - latency things.  Here if delay is more than minimum delay -> let use p-up
			    }

			    if (!can) return;
			    if (!player.HasInfinity) player.PayVault.Consume(new[] { powerup }, null);
			    _powerupUses[message.Type] = _powerupUses.ContainsKey(message.Type) ? _powerupUses[message.Type] + 1 : 1;
			    Guys[player.ConnectUserId].PowerupLastUses[message.Type] = DateTime.UtcNow;
			    _game.UsePowerup(player, message);
			});
		}		

		public void CleanUp()
		{
			Console.WriteLine("cleaned up");			
			Guys.Clear();
			Guys = new Dictionary<string, Player>();
			PlayersColors = new ArrayList();
			CreateRandomColors();
			_powerupUses = new Dictionary<string, uint>();
		}		
	}
}