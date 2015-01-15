using System.Collections;

namespace ServerSide.snake
{
	public class SnakePart:Cell
	{
		public int DirectionID;
		public bool DelayMove = false; //for growing
		public ArrayList FutureTurns = new ArrayList();

		//0 - right, 1 - down, 2 - left, 3 - up
		public SnakePart(int i, int j, int directionID, bool delayMove = false, ArrayList futureTurns = null)
		{
			I = i;
			J = j;

			DirectionID = directionID;
			DelayMove = delayMove;
			if (futureTurns != null) FutureTurns = futureTurns;	
		}

		public void Move()
		{
			if (!DelayMove)
			{
				if (FutureTurns.Count > 0)
				{
				    var turn = FutureTurns[0] as Turn;
				    if (turn != null && (turn.I == I && turn.J == J))
					{
						DirectionID = (FutureTurns[0] as Turn).DirectionID;
					//	Console.WriteLine("turned at: " + (futureTurns[0] as Turn).i + " - " + (futureTurns[0] as Turn).j);
						FutureTurns.RemoveAt(0);
					}
				}
			    MoveForward();
			}
			else DelayMove = false; //next time will move
		}

		private void MoveForward()
		{
			I = GetFutureCellI(DirectionID, I);
			J = GetFutureCellJ(DirectionID, J);
		}
		
		public static int GetFutureCellI(int direction, int currentI)
		{
			var result = currentI;
			switch (direction)
			{
			    case 0:
			        result = currentI == (SnakeData.FieldWidth - 1)? -1 : currentI + 1; 	 //right	
			        break;
			    case 2:
			        result = currentI == 0 ? SnakeData.FieldWidth : currentI - 1;  //left			
			        break;
			}
			return result;
		}
		
		public static int GetFutureCellJ(int direction, int currentJ)
		{
			var result = currentJ;
			switch (direction)
			{
			    case 1:
			        result = currentJ == (SnakeData.FieldHeight - 1)? -1 : currentJ + 1; //down				
			        break;
			    case 3:
			        result = currentJ == 0 ? SnakeData.FieldHeight : currentJ - 1; //up		
			        break;
			}
			return result;
		}

		public void AddFutureTurn(int i, int j, int direction)
		{
			FutureTurns.Add(new Turn(i, j, direction));
		}
	}
}
