using System;
using System.Collections;
using PlayerIO.GameLibrary;

namespace ServerSide.snake
{
	public class ArtificialPowerupsManager
	{
		private const int TimerBuffer = SnakeData.GameLength / 5; //about 13 seconds
		private const int LaunchBuffer = 8; //amount of cells snake will pass before powerup will be launched (anti-async)

		public Timer ReBoostTimer;

	    readonly GameManager _roomClass;
	    readonly OpponentsSnake _oppSnake;

		int _boost2XCount;
		int _boost3XCount;
		int _minesCount;
		int _missilesCount;

	    readonly ArrayList _timers = new ArrayList(); //at game finished all timers are stopped

		public ArtificialPowerupsManager(OpponentsSnake oppSnake, GameManager roomClass)
		{
			_roomClass = roomClass;
			_oppSnake = oppSnake;
			AssignFuturePowerups();
		}

		private void AssignFuturePowerups()
		{
			var random2XBoost = _roomClass.Rand.Next(100);
			if (random2XBoost < 10) _boost2XCount = 0;
			else if (random2XBoost >= 10 && random2XBoost < 30) _boost2XCount = 1;
			else _boost2XCount = 2;

			var random3XBoost = _roomClass.Rand.Next(100);
			if (random3XBoost < 20) _boost3XCount = 0;
			else if (random3XBoost >= 20 && random3XBoost < 40) _boost3XCount = 1;
			else _boost3XCount = 2;

			var randomMines = _roomClass.Rand.Next(100);
			if (randomMines < 60) _minesCount = 0;
			else if (randomMines >= 60 && randomMines < 95) _minesCount = 1;
			else _minesCount = 2;
			_minesCount = 2;

			var randomMissiles = _roomClass.Rand.Next(100);
			if (randomMissiles < 40) _missilesCount = 0;
			else if (randomMissiles >= 40 && randomMissiles < 80) _missilesCount = 1;
			else _missilesCount = 1;

			//**************On average: 1.6 2x boosts, 1.4 3x boosts, 0.45 mines, 0.8 missiles => more than 4 powerups from fake snake**********************//

			/*
			 * Planning all powerups at once. Creting a timer for each powerup launch.
			 * */
			if (_boost2XCount > 0) PlanBoosts2X();
			if (_boost3XCount > 0) PlanBoosts3X();
			if (_minesCount > 0) PlanMines();
			if (_missilesCount > 0) PlanMissiles();

			Console.WriteLine("boost2xCount: " + _boost2XCount);
			Console.WriteLine("boost3xCount: " + _boost3XCount);
			Console.WriteLine("minesCount: " + _minesCount);
			Console.WriteLine("missilesCount: " + _missilesCount);
		}

		private void PlanBoosts2X()
		{
		    switch (_boost2XCount)
		    {
		        case 1:
		            CreateTimer(Launch2XBoost, _roomClass.Rand.Next(SnakeData.GameLength - (SnakeData.GameLength / 3))); //boosts at 1st part of the game mainly, when there are a little fruits				
		            break;
		        case 2:
		            CreateTimer(Launch2XBoost, _roomClass.Rand.Next(SnakeData.GameLength / 4)); //launch at 1st third
		            CreateTimer(Launch2XBoost, (SnakeData.GameLength / 4) + TimerBuffer + _roomClass.Rand.Next(SnakeData.GameLength / 4));  //launch at 2nd third
		            break;
		    }
		}

	    private void PlanBoosts3X()
	    {
	        switch (_boost3XCount)
	        {
	            case 1:
	                CreateTimer(Launch3XBoost, _roomClass.Rand.Next(SnakeData.GameLength - (SnakeData.GameLength / 3))); //boosts at 1st part of the game mainly, when there are a little fruits				
	                break;
	            case 2:
	                CreateTimer(Launch3XBoost, _roomClass.Rand.Next(SnakeData.GameLength / 4)); //launch at 1st third
	                CreateTimer(Launch3XBoost, (SnakeData.GameLength / 4) + TimerBuffer + _roomClass.Rand.Next(SnakeData.GameLength / 4));  //launch at 2nd third
	                break;
	        }
	    }

	    private void PlanMines()
		{
		    switch (_minesCount)
		    {
		        case 1:
		            CreateTimer(LaunchSevenMines, _roomClass.Rand.Next(SnakeData.GameLength - TimerBuffer));
		            break;
		        case 2:
		            CreateTimer(LaunchSevenMines, _roomClass.Rand.Next(SnakeData.GameLength / 3)); //launch at 1st third
		            CreateTimer(LaunchSevenMines, (SnakeData.GameLength / 3) + TimerBuffer + _roomClass.Rand.Next(SnakeData.GameLength / 3));  //launch at 2nd third
		            break;
		    }
		}

	    private void PlanMissiles()
	    {
	        switch (_missilesCount)
	        {
	            case 1:
	                CreateTimer(LaunchMissile, _roomClass.Rand.Next(SnakeData.GameLength - TimerBuffer));
	                break;
	            case 2:
	                CreateTimer(LaunchMissile, _roomClass.Rand.Next(SnakeData.GameLength / 3)); //launch at 1st third
	                CreateTimer(LaunchMissile, (SnakeData.GameLength / 3) + TimerBuffer + _roomClass.Rand.Next(SnakeData.GameLength / 3));  //launch at 2nd third
	                break;
	        }
	    }

	    private void CreateTimer(Action callback, int time)
		{
			var timer = _roomClass.ScheduleCallback(callback, time);
			_timers.Add(timer);
		}

		private void Launch2XBoost()
		{
			DoBoost(false);		
		}

		private void Launch3XBoost()
		{
			DoBoost(true);		
		}

		private void DoBoost(bool triple)
		{
			if (_oppSnake.FutureBoost == null && _oppSnake.BoostType == 1)
			{
				var targetCellData = GetTargetCellData();
				_oppSnake.NoRandomTurnCounter = OpponentsSnake.BoostLength + LaunchBuffer + 2; //2 extra cells for 100% guarantee of no-turn
				_roomClass.Creator.Send(triple ? "bo3" : "bo2", targetCellData[0], targetCellData[1], targetCellData[2], targetCellData[3]);
				_oppSnake.PrepareForBoost(targetCellData, triple);
			}
			else
			{
				Console.WriteLine("Currently at boost, postponing boost for 7 sec");
				ReBoostTimer = _roomClass.ScheduleCallback(() => DoBoost(triple), 7000);
			}
		}

		private void LaunchSevenMines()
		{
			var targetCellData = GetTargetCellData();
			_oppSnake.NoRandomTurnCounter = OpponentsSnake.BoostLength + LaunchBuffer + 2; //2 extra cells for 100% guarantee of no-turn
			_oppSnake.PrepareForMines(targetCellData);
			_roomClass.Creator.Send("sm", targetCellData[0], targetCellData[1], targetCellData[2], targetCellData[3]);			
		}

		private void LaunchMissile()
		{
			var targetCellData = GetTargetCellData();
			_oppSnake.NoRandomTurnCounter = OpponentsSnake.BoostLength + LaunchBuffer + 2; //2 extra cells for 100% guarantee of no-turn
			_roomClass.Creator.Send("mi", targetCellData[0], targetCellData[1], targetCellData[2], targetCellData[3]);
			//nothing is done at server. Kinda tough to duplicate missile client logic
		}

		private int[] GetTargetCellData()
		{
			var preTargetCellI = 0; //saving and sending 3 cells, so when snake makes a loop (in those 8 cells go twice through the target cell) it will not launch boost earlier 
			var preTargetCellJ = 0;
			var targetCellI = 0;
			var targetCellJ = 0;

			var currentSnakeI = _oppSnake.Head.I;
			var currentSnakeJ = _oppSnake.Head.J;
			var currentDirection = _oppSnake.Head.DirectionID;
			var currentFutureTurn = 0;

			for (var i = 0; i < LaunchBuffer + 2; i++)
			{
			    var o = _oppSnake.FutureTurns[currentFutureTurn] as DatabaseObject;
			    if (o != null && (_oppSnake.FutureTurns.Count > currentFutureTurn && o.GetInt("i") == currentSnakeI && o.GetInt("j") == currentSnakeJ)) //snake will make a turn here
				{
					Console.WriteLine("future turn at planning powerup!");
				    var databaseObject = _oppSnake.FutureTurns[currentFutureTurn] as DatabaseObject;
				    currentDirection = databaseObject.GetInt("direction");
				    currentFutureTurn++;
				}

				currentSnakeI = SnakePart.GetFutureCellI(currentDirection, currentSnakeI);
				currentSnakeJ = SnakePart.GetFutureCellJ(currentDirection, currentSnakeJ);

				if (i == LaunchBuffer - 1)
				{
					preTargetCellI = currentSnakeI;
					preTargetCellJ = currentSnakeJ;
				}
				else if (i == LaunchBuffer)
				{
					targetCellI = currentSnakeI;
					targetCellJ = currentSnakeJ;
				}
			}

			Console.WriteLine("preTargetCellI: " + preTargetCellI);
			Console.WriteLine("preTargetCellJ: " + preTargetCellJ);
			Console.WriteLine("targetCellI: " + targetCellI);
			Console.WriteLine("targetCellJ: " + targetCellJ);
			Console.WriteLine("-------------------------------------");

			int[] result = { preTargetCellI, preTargetCellJ, targetCellI, targetCellJ };
			return result;
		}
	}
}
