using System;
using System.Collections;

namespace ServerSide.snake
{
	public class UserSnake
	{
		public const int StartSnakeSize = 3;
		private const int CrazyLength = 20; //when hit mine or missile ~5 sec of crazy state (no movement)

		public int MinesRequestedCounter;
		public ArrayList Parts = new ArrayList();
		private readonly ArrayList _fruitsLink;
		private readonly ArrayList _minesLink;
		protected GameManager RoomClass;
		protected int ReabilitationCounter;
		//0 - right, 1 - down, 2 - left, 3 - up

		public UserSnake(int startPositionID, ArrayList fruits, ArrayList minesAlive, GameManager roomClass)
		{
			RoomClass = roomClass;

			for (var i = 0; i < StartSnakeSize; i++) //creating 3 snake pra
			{
			    var adjuster = i - (StartSnakeSize - 1);
			    switch (SnakeData.Directions[startPositionID])
			    {
			        case 0:
			            Parts.Add(new SnakePart(SnakeData.PositionsI[startPositionID] + adjuster, SnakeData.PositionsJ[startPositionID], SnakeData.Directions[startPositionID]));
			            break;
			        case 1:
			            Parts.Add(new SnakePart(SnakeData.PositionsI[startPositionID], SnakeData.PositionsJ[startPositionID] + adjuster, SnakeData.Directions[startPositionID]));
			            break;
			        case 2:
			            Parts.Add(new SnakePart(SnakeData.PositionsI[startPositionID] - adjuster, SnakeData.PositionsJ[startPositionID], SnakeData.Directions[startPositionID]));
			            break;
			        case 3:
			            Parts.Add(new SnakePart(SnakeData.PositionsI[startPositionID], SnakeData.PositionsJ[startPositionID] - adjuster, SnakeData.Directions[startPositionID]));
			            break;
			    }
			}

		    _fruitsLink = fruits;
			_minesLink = minesAlive;
		}

		public void MoveAndTurn(int i, int j, int turnDirection)
		{
			foreach (SnakePart part in Parts) part.AddFutureTurn(i, j, turnDirection);
			MoveForward();
		}

		public void MoveForward()
		{
			foreach (SnakePart part in Parts) part.Move();
			HitTest();
		}

		private void HitTest()
		{
			HitTestMyself();
			HitTestFruits();
			HitTestMines();
		}

		private void HitTestMyself()
		{
			for (var i = 0; i < Parts.Count - 1; i++)
			{
			    var snakePart = Parts[i] as SnakePart;
			    if (snakePart != null && (snakePart.I != Head.I || snakePart.J != Head.J)) continue;
			    var amountEaten = i + 1;
			    Console.WriteLine("eaten itself. coordinates: " + Head.I + " - " + Head.J + " amount eaten: " + amountEaten);
			    for (var j = i; j >= 0; j--) //remove eaten parts of the snake
			    {
			        Console.WriteLine("parts.count: " + Parts.Count);
			        Parts.RemoveAt(0);
			    }
			    break;
			}
		}

		private void HitTestFruits()
		{
		    for (var i = 0; i < _fruitsLink.Count; i++)
			{
			    var fruit = (_fruitsLink[i] as Fruit);

			    if (fruit != null && (fruit.I != Head.I || fruit.J != Head.J)) continue;
			    Console.WriteLine("eaten at: " + Head.I + " - " + Head.J);
			    if (fruit != null) _fruitsLink.Remove(fruit);
			    Grow();
			    return;
			}
		}

		private void HitTestMines()
		{
		    for (var i = 0; i < _minesLink.Count; i++)
			{
			    var mine = (_minesLink[i] as Mine);
			    if (mine != null && (mine.Author == this || mine.I != Head.I || mine.J != Head.J)) continue;
			    Console.WriteLine("hit mine at: " + Head.I + " - " + Head.J);
			    if (mine != null) _minesLink.Remove(mine);
			    GoCrazy();
			    return;
			}
		}

		public void GoCrazy()
		{
			ReabilitationCounter = CrazyLength;
		}

		public void Grow()
		{
			Parts.Insert(0, new SnakePart(Tail.I, Tail.J, Tail.DirectionID, true, CopyFutureTurns(Tail.FutureTurns)));
		}

	    public ArrayList CopyFutureTurns(ArrayList oldlist)
		{
			var newlist = new ArrayList();
	        foreach (Turn turn in oldlist)
	        {
	            newlist.Add(new Turn(turn.I, turn.J, turn.DirectionID));
	        }
	        return newlist;
		}

		public SnakePart Head
		{
			get
			{
				return Parts[Parts.Count - 1] as SnakePart;				
			}
		}

		public SnakePart Tail
		{
			get
			{
				return Parts[0] as SnakePart;
			}
		}
	}
}