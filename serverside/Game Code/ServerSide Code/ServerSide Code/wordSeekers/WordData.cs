namespace ServerSide.wordSeekers
{
	class WordData
	{
		public int RowIndex = 0;
		public int ColumnIndex = 0;
		public bool Horizontal = false;
		public string Word = "";

		public WordData(int rowIndexx, int columnIndexx, bool horizontall, string word = "")
		{
			RowIndex = rowIndexx;
			ColumnIndex = columnIndexx;
			Horizontal = horizontall;
			Word = word;
		}
	}
}
