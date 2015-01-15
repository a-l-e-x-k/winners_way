namespace ServerSide.snake
{
	class Turn:Cell
	{
		public int DirectionID;

		public Turn(int i, int j, int directionID)
		{
			I = i;
			J = j;
			DirectionID = directionID;
		}
	}
}
