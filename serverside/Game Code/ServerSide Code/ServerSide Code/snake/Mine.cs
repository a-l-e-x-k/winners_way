namespace ServerSide.snake
{
	public class Mine:Cell
	{		
		public UserSnake Author;

		public Mine(UserSnake author, int ii, int jj)
		{
			Author = author;
			I = ii;
			J = jj;
		}
	}
}
