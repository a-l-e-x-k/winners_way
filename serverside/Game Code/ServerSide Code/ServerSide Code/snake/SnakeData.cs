namespace ServerSide.snake
{
	class SnakeData
	{
		public const int TotalFields = 3;
		public const int FieldWidth = 33;
		public const int FieldHeight = 26;
		public const int FruitsCount = 4;
		public const int GameLength = 80 * 1000;

		public static int[] PositionsI
		{
			get
			{
				int[] positionsI = { 6, 6, 6, 7, 8, 12, 12, 15, 16, 19, 19, 21, 21, 25, 26, 27, 27, 11, 18, 17, 23 };
				return positionsI;
			}
		}

		public static int[] PositionsJ
		{
			get
			{
				int[] positionsJ = { 6, 13, 20, 17, 9, 6, 20, 8, 19, 6, 21, 10, 17, 9, 18, 6, 13, 12, 11, 14, 15 };
				return positionsJ;
			}
		}

		public static int[] Directions
		{
			get
			{
				int[] positionsDirections = { 0, 0, 0, 0, 0, 1, 3, 1, 3, 1, 3, 1, 3, 2, 2, 2, 2, 0, 1, 2, 3 };
				return positionsDirections;
			}
		}		
	}
}
