using System;
using System.Globalization;
using PlayerIO.GameLibrary;

namespace ServerSide
{
	public abstract class AsyncWordSeekers : WordSeekersScenarioCreator
	{
		private DatabaseObject _savedGamesCounter;
		public DatabaseArray DummyOpenedWords;

		protected void StartWordSeekersAdminGame()
		{
			Console.WriteLine("startSnakeAdminGame");
			PlayerIO.BigDB.Load("WordSeekersGames", "scenarioCount", OnScenarioCountLoaded, HandleError);
		}

		protected void LoadWordSeekersGamesCounter()
		{
			if (Creator.PlayerObject.Contains("oWS")) 
                PlayerIO.BigDB.Load("WordSeekersGames", "1", OnWordSeekersRecordedGameLoaded, HandleError); //game with word "flower" for newbie
			else 
                PlayerIO.BigDB.Load("WordSeekersGames", "count", OnWordSeekersCountLoaded, HandleError);
		}

		private void OnWordSeekersCountLoaded(DatabaseObject savedGamesCounter)
		{
			_savedGamesCounter = savedGamesCounter;
			Console.WriteLine("onCountLoaded");
			GameID = ScenarioReloadCounter < MaxScenarioReloadCount ? Rand.Next(savedGamesCounter.GetInt("value") + 1) : 1;
			PlayerIO.BigDB.Load("WordSeekersGames", GameID.ToString(CultureInfo.InvariantCulture), OnWordSeekersRecordedGameLoaded, HandleError);
		}

		private void OnWordSeekersRecordedGameLoaded(DatabaseObject recordedGame)
		{
			if (!recordedGame.Contains("uid")) 
                OnWordSeekersCountLoaded(_savedGamesCounter); //loaded game object may be empty
			else if (recordedGame.GetString("uid") == Creator.ConnectUserId) //admin can play with himself
			{
				ScenarioReloadCounter++;
				OnWordSeekersCountLoaded(_savedGamesCounter);
			}
			else
			{
				Console.WriteLine("onRecordedGameLoaded");
				ScenarioNumber = recordedGame.GetInt("scenario");
				DummyOpenedWords = recordedGame.GetArray("openedWords");
				//get array of opened words
				//opened word: timeSpent, word, coordI, coordJ

				var fakePlayer = new Player {IsDummy = true, ID = recordedGame.GetString("uid")};
			    Guys[recordedGame.GetString("uid")] = fakePlayer;
				Guys[recordedGame.GetString("uid")].Create((int)PlayersColors[Guys.Count - 1], false);
				PlayerIO.BigDB.Load("PlayerObjects", recordedGame.GetString("uid"), SendUsersInfo, HandleError);
				ScenarioReloadCounter = 0;
			}
		}
	}
}
