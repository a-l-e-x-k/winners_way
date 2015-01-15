using System;
using System.Collections;
using System.Globalization;
using PlayerIO.GameLibrary;
using ServerSide.snake;

namespace ServerSide
{
	public abstract class AsyncSnake : DataUpdater
	{
		protected const int MaxScenarioReloadCount = 2;
		public int ScenarioNumber;
		public DatabaseArray DummyTurns;

		protected ArrayList PlayersColors = new ArrayList(); //at gameCreate colors are defined. Fixes problem when 2 guys simultaneously grab 1 exact color
		protected int GameID; //is sent 2 user. So he can load turns. scenario #, start position, uid is used by server and transferred by msg when needed
		protected int ScenarioReloadCounter;

		private DatabaseObject _savedGamesCounter;

		protected void StartSnakeAdminGame()
		{
			Console.WriteLine("startSnakeAdminGame");
			PlayerIO.BigDB.Load("SnakeGames", "scenarioCount", OnScenarioCountLoaded, HandleError);
		}

		protected void LoadSnakeGamesCounter()
		{
			PlayerIO.BigDB.Load("SnakeGames", "count", OnSnakeCountLoaded, HandleError);
		}

		private void OnSnakeCountLoaded(DatabaseObject savedGamesCount)
		{
			_savedGamesCounter = savedGamesCount;
			Console.WriteLine("onCountLoaded");
			GameID = ScenarioReloadCounter < MaxScenarioReloadCount ? Rand.Next(savedGamesCount.GetInt("value") + 1) : 1;
			PlayerIO.BigDB.Load("SnakeGames", GameID.ToString(CultureInfo.InvariantCulture), OnSnakeRecordedGameLoaded, HandleError);
		}

		private void OnSnakeRecordedGameLoaded(DatabaseObject recordedGame)
		{
			if (!recordedGame.Contains("uid")) OnSnakeCountLoaded(_savedGamesCounter); //loaded game object may be empty
			else if (recordedGame.GetString("uid") == Creator.ConnectUserId) //admin can play with himself
			{
				ScenarioReloadCounter++;
				OnSnakeCountLoaded(_savedGamesCounter);
			}
			else
			{
				Console.WriteLine("onRecordedGameLoaded");
				ScenarioNumber = recordedGame.GetInt("scenario");
				DummyTurns = recordedGame.GetArray("turnsArray");
				var fakePlayer = new Player {IsDummy = true, ID = recordedGame.GetString("uid")};
			    Guys[recordedGame.GetString("uid")] = fakePlayer;
				Guys[recordedGame.GetString("uid")].Create((int)PlayersColors[Guys.Count - 1], false);
				Guys[recordedGame.GetString("uid")].DummyStartPosition = recordedGame.GetInt("startPosition");
				PlayerIO.BigDB.Load("PlayerObjects", recordedGame.GetString("uid"), SendUsersInfo, HandleError);
				ScenarioReloadCounter = 0;
			}
		}

		protected void Create100FruitScenarios()
		{
			var counter = 0;
			for (var i = 0; i < 100; i++)
			{
				ScheduleCallback(delegate
				{
					CreateFruitScenario(counter);
					counter++;
				}, 200 * i + 25);
			}
		}

		private void CreateFruitScenario(int iii)
		{
			var obj = new DatabaseObject();
			var scenario = new DatabaseArray();

			AddRandomFruit(scenario, 500 + Rand.Next(500));
			AddRandomFruit(scenario, 400 + Rand.Next(500));
			AddRandomFruit(scenario, 1100 + Rand.Next(500));
			AddRandomFruit(scenario, 1000 + Rand.Next(500));

			var fruitCount = 100 + Rand.Next(10); //enough for ~100 seconds-game
			for (var i = 0; i < fruitCount; i++)
			{
				AddRandomFruit(scenario, 500 + Rand.Next(800)); //on avg every 1.4 secs fruit is created
			}

			obj.Set("scenario", scenario);
			PlayerIO.BigDB.CreateObject("SnakeFruitScenarios", iii.ToString(CultureInfo.InvariantCulture), obj, delegate { Console.WriteLine("scenarios created"); }, HandleError);
		}

		private void AddRandomFruit(DatabaseArray arr, int delay)
		{
			var fruit = new DatabaseObject();
			var randomI = Rand.Next(SnakeData.FieldWidth - 4) + 3; //-+2 - beacuse no need 2 place fruits at borders
			var randomJ = Rand.Next(SnakeData.FieldHeight - 4) + 3;
			fruit.Set("i", randomI);
			fruit.Set("j", randomJ);
			fruit.Set("delay", delay);
			arr.Add(fruit);
		}

		protected virtual void SendUsersInfo(DatabaseObject opponentObj) { } //func in AsyncFunctional
		protected virtual void OnScenarioCountLoaded(DatabaseObject scenarioCount) { } //func in AsyncFunctional
	}
}
