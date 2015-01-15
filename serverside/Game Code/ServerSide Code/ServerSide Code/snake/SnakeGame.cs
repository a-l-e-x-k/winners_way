using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using PlayerIO.GameLibrary;

namespace ServerSide.snake
{
	public class SnakeGame : Game
	{
		public const int MinesInSet = 7;

		private readonly ArrayList _minesAlive = new ArrayList(); //used by opp's snake only. To stop when hit the mine
		private readonly ArrayList _fruitsAlive = new ArrayList();
	    private Timer _fruitTimer;
		private Timer _oppMoveTimer;

		private OpponentsSnake _oppSnake;
		private ArtificialPowerupsManager _artPowerupsManager;
		private UserSnake _mySnake;

		private DatabaseArray _fruitScenario;
		private readonly ArrayList _recordedTurns = new ArrayList(); //turns for each guy are recorded
		private int _startPosition;

		private bool _missileAllowed; //turned to false when guy hit the snake and oppSnake stops for a while
		private int _minesUseAllowed = 1; //++ when mine placement start. 1 - when used powerup. True initialy for latency-independant powerup use while protecting from heavy cheating

		public SnakeGame(Dictionary<string, Player> guys, GameManager roomClass)
		{
			Guys = guys;
			RoomClass = roomClass;
			roomClass.PlayerIO.BigDB.Load("SnakeFruitScenarios", roomClass.ScenarioNumber.ToString(CultureInfo.InvariantCulture), StartGame, roomClass.HandleError);
		}

		private void StartGame(DatabaseObject fruitScenarioObj)
		{
			Console.WriteLine("startGame");
			_fruitScenario = fruitScenarioObj.GetArray("scenario");

			var usedPositions = new ArrayList();
		    foreach (var guyId in Guys.Keys)
			{
			    int randomPosition;
			    if (Guys[guyId].IsDummy) //position of opponent is saved, so just inserting it here
				{
					randomPosition = Guys[guyId].DummyStartPosition;
					_oppSnake = new OpponentsSnake(randomPosition, _fruitsAlive, _minesAlive, RoomClass, RoomClass.DummyTurns, this);
					_artPowerupsManager = new ArtificialPowerupsManager(_oppSnake, RoomClass);
				}
				else
				{
					do randomPosition = Rand.Next(SnakeData.PositionsI.Length);
					while (usedPositions.Contains(randomPosition));

					_startPosition = randomPosition;
					_mySnake = new UserSnake(randomPosition, _fruitsAlive, _minesAlive, RoomClass);
				}
				usedPositions.Add(randomPosition);
			}

			RoomClass.ScheduleCallback(delegate
			{
				foreach (var dude in Guys.Values)
				{
					dude.Points = (dude.IsDummy ? _oppSnake.Parts.Count : _mySnake.Parts.Count) - 3; //final result = length of the snake - 3
				}
				RoomClass.SaveRecordedSnakeGame(RoomClass.ScenarioNumber, _recordedTurns, _startPosition);
				_fruitTimer.Stop();
				_oppMoveTimer.Stop();
				if (_artPowerupsManager.ReBoostTimer != null) _artPowerupsManager.ReBoostTimer.Stop();
				FinishGame();
			}, SnakeData.GameLength);

			_oppMoveTimer = RoomClass.AddTimer(MoveOppSnake, 250);

			var bgType = RoomClass.Creator.PlayerObject.Contains("oSN") ? 2 : Rand.Next(SnakeData.TotalFields); //select bg. (glade, forest, desert)
			var positions = "";
			for (var i = 0; i < usedPositions.Count; i++) 
                positions += usedPositions[i] + (i == (usedPositions.Count - 1) ? "" : ",");
			RoomClass.Creator.Send("st", positions, bgType); //send everybody positions list && fruits
			CreateFruit();
		}

		public override void HandleSpecialMessage(Player player, Message message)
		{
		    switch (message.Type)
		    {
		        case "0":
		            ProcessCellData(player, message); //move with turn
		            break;
		        case "rf":
		            RemoveFruitAt(message.GetInt(0), message.GetInt(1));//remove fruit (if somehow coordinates were wrong (some snake part is at this coords))
		            break;
		        case "mibo":
		            if (_missileAllowed)
		            {
		                _oppSnake.GoCrazy();
		                _missileAllowed = false;
		            } //else - cheater. missileAllowed is set to true when launched missile
		            break;
		    }
		}

	    public override void UsePowerup(Player player, Message message)
	    {
	        switch (message.Type)
	        {
	            case "sm":
	                Console.WriteLine("sm!!!!!!!!!!!!!!!!!!!!!!!!!!");
	                _minesUseAllowed++;
	                break;
	            case "bo3":
	            case "bo2":
	                RoomClass.Creator.Send(message.Type); //boosters confirmed
	                break;
	            case "mi":
	                _missileAllowed = true;
	                player.Send(message.Type); //client will place missile in prepare mode (it won't move but will be "getting ready")
	                break;
	            case "gr":
	                player.Send(message.Type); //just confirming that grid is aviable
	                break;
	        }
	    }

	    private void ProcessCellData(BasePlayer player, Message message)
		{
			var plid = player.ConnectUserId;
	        if (!Guys.ContainsKey(plid)) return;
	        if (_mySnake.MinesRequestedCounter > 0) TryPlaceMine(_mySnake);
	        if (message.Count > 2) //if turn was made
	        {
	            if (message.Count == 4 && _minesUseAllowed > 0)
	            {
	                _minesUseAllowed--;
	                _mySnake.MinesRequestedCounter = MinesInSet;
	                TryPlaceMine(_mySnake);
	            }
	            SaveTurnData(message.GetInt(0), message.GetInt(1), message.GetInt(2));
	            _mySnake.MoveAndTurn(message.GetInt(0), message.GetInt(1), message.GetInt(2));
	        }
	        else
	        {
	            if (message.Count == 1 && _minesUseAllowed > 0)
	            {
	                _minesUseAllowed--;
	                _mySnake.MinesRequestedCounter = MinesInSet;
	                TryPlaceMine(_mySnake);
	            }
	            _mySnake.MoveForward(); //just move snake in current direction 
	        }
		}

		private void MoveOppSnake()
		{
			if (_oppSnake.MinesRequestedCounter > 0) TryPlaceMine(_oppSnake);
			_oppSnake.MoveWithCheck();
		}

		public void TryPlaceMine(UserSnake mineAuthor) //oppSnake calls it when entered target cell
		{
			var clearCell = true;
			foreach (Mine mine in _minesAlive)
			{
			    if (mine.I == mineAuthor.Tail.I && mine.J == mineAuthor.Tail.J) clearCell = false;
			}

		    var notAtFieldBorder = !(mineAuthor.Tail.I == -1 || mineAuthor.Tail.I == SnakeData.FieldWidth || mineAuthor.Tail.J == SnakeData.FieldHeight || mineAuthor.Tail.J == -1);

		    if (!clearCell || !notAtFieldBorder) return;
		    Console.WriteLine("--------------------------------------------------------------");
		    Console.WriteLine("placing mine at: " + mineAuthor.Tail.I + " : " + mineAuthor.Tail.J);
		    
            var newMine = new Mine(mineAuthor, mineAuthor.Tail.I, mineAuthor.Tail.J);
		    _minesAlive.Add(newMine);
		    mineAuthor.MinesRequestedCounter--;
		}

		private void SaveTurnData(int i, int j, int direction)
		{
			var turnObject = new DatabaseObject();
			turnObject.Set("i", i);
			turnObject.Set("j", j);
			turnObject.Set("direction", direction);
			_recordedTurns.Add(turnObject);
		}

		private void CreateFruit()
		{
		    if (!(_fruitsAlive.Count < 0.5*SnakeData.FieldHeight*SnakeData.FieldWidth)) return;
		    var fruitType = Rand.Next(SnakeData.FruitsCount);
		    var fruitObj = (DatabaseObject)_fruitScenario[0];
		    var fruitI = fruitObj.GetInt("i");
		    var fruitJ = fruitObj.GetInt("j");
		    var checkPassed = true;

		    if (_fruitScenario.Count > 1)
		    {
		        var databaseObject = _fruitScenario[1] as DatabaseObject;
		        if (databaseObject != null)
		            _fruitTimer = RoomClass.ScheduleCallback(CreateFruit, databaseObject.GetInt("delay")); //if there is a next fruit, create it with it's delay
		    }

		    for (var i = 0; i < _fruitsAlive.Count; i++)
		    {
		        var fruit = _fruitsAlive[i] as Fruit;
		        if (fruit != null && (Math.Abs(fruit.I - fruitI) > 2 || Math.Abs(fruit.J - fruitJ) > 2)) continue;
		        checkPassed = false;
		        break;
		    }

		    foreach (SnakePart part in _oppSnake.Parts)
		    {
		        if (Math.Abs(part.I - fruitI) >= 3 || Math.Abs(part.J - fruitJ) >= 3) continue;
		        checkPassed = false;
		        break;
		    }

		    foreach (SnakePart part in _mySnake.Parts)
		    {
		        if (Math.Abs(part.I - fruitI) >= 3 || Math.Abs(part.J - fruitJ) >= 3) continue;
		        checkPassed = false;
		        break;
		    }

		    if (checkPassed) //NB: if snake is there -> we don't care, because check is made on client. In case we missed and placed item near the tail, e.g.
		    {
		        _fruitsAlive.Add(new Fruit(fruitType, fruitI, fruitJ));
		        RoomClass.Creator.Send("f", fruitI, fruitJ, fruitType);
		    }

		    _fruitScenario.RemoveAt(0);
		}

		private void RemoveFruitAt(int i, int j)
		{
			for (var o = 0; o < _fruitsAlive.Count; o++)
			{
			    if ((_fruitsAlive[o] as Fruit) == null || (_fruitsAlive[o] as Fruit).I != i || (_fruitsAlive[o] as Fruit).J != j)
			        continue;
			    if (_fruitsAlive.Count < o) _fruitsAlive.RemoveAt(o);
			}
		}
	}
}