using System;
using System.Collections;
using System.Globalization;
using PlayerIO.GameLibrary;
using ServerSide.wordSeekers;

namespace ServerSide
{
	public abstract class WordSeekersScenarioCreator : AsyncSnake
	{
		private const string NubeWord = "цветок";
		private const int NumOfWords = 10;

		protected void Create100WordsScenarios()
		{
			var counter = 0;
			for (var i = 0; i < 100; i++)
			{
				ScheduleCallback(delegate
				{
					CreateWordScenario(counter);
					counter++;
				}, 400 * i + 25);
			}
		}

		private void CreateWordScenario(int scenarioID)
		{
			var obj = new DatabaseObject();

			var rowsArr = new ArrayList();
			var wordsArr = new ArrayList();
			CreateFieldWithWordsOnly(rowsArr, wordsArr);

			if (scenarioID == 0) 
                InsertWord(NubeWord, true, rowsArr, 8, 4);
			FillEmptyCellsWithRandomLetters(rowsArr);

			var words = CreateDatabaseArrayOfWords(wordsArr);
			var field = CreateFieldArray(rowsArr);

			obj.Set("words", words);
			obj.Set("field", field);
			PlayerIO.BigDB.CreateObject("WordsScenarios", scenarioID.ToString(CultureInfo.InvariantCulture), obj, delegate { Console.WriteLine("scenarios created"); }, HandleError);
		}

		private void CreateFieldWithWordsOnly(ArrayList rows, ArrayList words)
		{
			for (var i = 0; i < WordSeekers.SizeY; i++) //rows
			{
				rows.Add(new ArrayList());
                for (var j = 0; j < WordSeekers.SizeX; j++) //columns
				{
					((ArrayList)rows[i]).Add("");
				}
			}

			var word = Data.Fruits[Rand.Next(Data.Fruits.Length)];
		    var notInserted = true;
		    const int insertAttemptsNumber = 100;

		    for (var w = 0; w < NumOfWords; w++)
			{
				Console.WriteLine("w: " + w);
				var insertAttemptsCounter = 0;
				while (notInserted && insertAttemptsCounter < insertAttemptsNumber)
				{
					var horizontal = Rand.Next(2) == 1;
					var sizeThatMatters = horizontal ? WordSeekers.SizeX : WordSeekers.SizeY;
					var maxFirstLetterIndex = sizeThatMatters - word.Length - 1;
					var row = Rand.Next(sizeThatMatters - maxFirstLetterIndex);
					var column = Rand.Next(sizeThatMatters - maxFirstLetterIndex);
					var willFit = true; //var for checking whether all the word will fit or not
					for (var i = 0; i < word.Length; i++) //check if all cells for the word at current start index are empty 
					{
						if (horizontal)
						{
							if ((column + i) >= sizeThatMatters || (string)((ArrayList)rows[row])[column + i] != "")
							{
								willFit = false;
							}
						}
						else
						{
							if ((row + i) >= sizeThatMatters || (string)((ArrayList)rows[row + i])[column] != "")
							{
								willFit = false;
							}
						}
					}

					if (willFit)
					{
						InsertWord(word, horizontal, rows, row, column);
						words.Add(new WordData(row, column, horizontal, word));
						notInserted = false;
						Console.WriteLine("Inserted from " + insertAttemptsCounter + " attempts");
					}

					insertAttemptsCounter++;
				}

				notInserted = true;
				bool newWordFound = false;
				string randomWord = "";
				while (!newWordFound)
				{
					randomWord = Data.Fruits[Rand.Next(Data.Fruits.Length - 1)];
					if (NoSuchWord(randomWord, words)) 
                        newWordFound = true;
				}
				word = randomWord;
			}
		}

		private static bool NoSuchWord(string word, ArrayList wordDataArr)
		{
			var result = true;
			foreach (WordData data in wordDataArr)
			{
				if (data.Word == word) result = false;
			}
			return result;
		}
        
		private static void InsertWord(string word, bool horizontal, ArrayList rows, int row, int column)
		{
			for (var i = 0; i < word.Length; i++) //insert word
			{
				if (horizontal)
				{
					((ArrayList)rows[row])[column + i] = word.Substring(i, 1);
				}
				else
				{
					((ArrayList)rows[row + i])[column] = word.Substring(i, 1);
				}
			}
		}

		private void FillEmptyCellsWithRandomLetters(IList rows)
		{
			for (var i = 0; i < WordSeekers.SizeY; i++) //rows
			{
				for (var j = 0; j < WordSeekers.SizeX; j++) //columns
				{
                    if (((string)((IList)rows[i])[j]) == "") 
                        ((IList)rows[i])[j] = (Data.Letters[Rand.Next(Data.Letters.Length)]);
				}
			}
		}

	    public DatabaseArray CreateDatabaseArrayOfWords(ArrayList wordData)
		{
			var result = new DatabaseArray();
			foreach (WordData data in wordData)
			{
				var wordObject = new DatabaseObject();
				wordObject.Set("word", data.Word);
				wordObject.Set("rowIndex", data.RowIndex);
				wordObject.Set("columnIndex", data.ColumnIndex);
				wordObject.Set("horizontal", data.Horizontal);
				result.Add(wordObject);
			}
			return result;
		}

		private static DatabaseArray CreateFieldArray(IEnumerable rows)
		{
			var result = new DatabaseArray();
			foreach (var t in rows)
			{
			    var row = new DatabaseArray();
			    if (t != null)
			    {
                    for (var j = 0; j < (t as ArrayList).Count; j++) //going through all letters in row
                    {
                        row.Add((t as ArrayList)[j] as string);
                    }
			    }
			    result.Add(row);
			}
			return result;
		}
	}
}
