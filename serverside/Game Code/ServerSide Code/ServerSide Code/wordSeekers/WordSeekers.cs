using System;
using System.Collections;
using System.Collections.Generic;
using System.Globalization;
using PlayerIO.GameLibrary;

namespace ServerSide.wordSeekers
{
	public class WordSeekers : Game
	{
		public const int SizeX = 15; //Scenatios in BigDb are created with this size. Re-create scenarios if changing field size.
		public const int SizeY = 12;
		private const int GameLength = 60 * 1000;
		private readonly Dictionary<string, WordData> _words = new Dictionary<string, WordData>();
		private readonly ArrayList _openedWords = new ArrayList();
		private int _atOpenedWordIndex = -1;
		private Timer _gameTimer;
		private Timer _fruitOpeningTimer;
		private int _gameStartedAtSeconds; //UNIX seconds of game start

		public WordSeekers(Dictionary<string, Player> guys, GameManager roomClass)
		{
			Guys = guys;
			RoomClass = roomClass;
			roomClass.PlayerIO.BigDB.Load("WordsScenarios", 
                roomClass.ScenarioNumber.ToString(CultureInfo.InvariantCulture), StartGame, roomClass.HandleError);
		}

		private void StartGame(DatabaseObject wordsScenarioObj)
		{
			foreach (DatabaseObject word in wordsScenarioObj.GetArray("words"))
			{
				_words[word.GetString("word")] = new WordData(word.GetInt("rowIndex"), word.GetInt("columnIndex"), word.GetBool("horizontal"));
			}
			
			if (RoomClass.Creator.PlayerObject.Contains("oWS")) 
            {
                RoomClass.RemoveTutorialProperty("oWS", RoomClass.Creator);
            } //insert a flower word (used in tutorial at client) & unnewbiefie nubes
			RoomClass.Creator.Send("st");
			_gameTimer = RoomClass.ScheduleCallback(DoFinish, GameLength);
			_gameStartedAtSeconds = (int)(DateTime.UtcNow - new DateTime(1970, 1, 1, 0, 0, 0)).TotalSeconds;

			ScheduleNextFruitOpening();
		}

		private void TryOpenWordByDummy()
		{
			var openedWord = (RoomClass.DummyOpenedWords[_atOpenedWordIndex] as DatabaseObject);
		    if (openedWord != null)
		    {
		        Console.WriteLine("onWORDOPENED: " + openedWord.GetString("word"));
		        if (_words.ContainsKey(openedWord.GetString("word")) && WordNotOpened(openedWord.GetString("word"))) //if word exists and wasn't opened yet				
		        {
		            InsertWord(GetOppID(), openedWord.GetString("word"), openedWord.GetInt("rowIndex"), openedWord.GetInt("columnIndex"));
		            RoomClass.Creator.Send("wc", false, openedWord.GetString("word"), openedWord.GetInt("rowIndex"), openedWord.GetInt("columnIndex"));
		        }
		    }
		    ScheduleNextFruitOpening();			
		}

		private void ScheduleNextFruitOpening()
		{
		    _atOpenedWordIndex++;
		    var databaseObject = RoomClass.DummyOpenedWords[_atOpenedWordIndex] as DatabaseObject;
		    if (databaseObject != null)
		        _fruitOpeningTimer = RoomClass.ScheduleCallback(TryOpenWordByDummy, databaseObject.GetInt("timeSpent") * 1000);
		}

	    public override void HandleSpecialMessage(Player player, Message message) //Message: 0 - word, 1 - rowIndex, 2 - columnIndex
		{
			if (message.Type == "ws")
			{
				Console.WriteLine(message.GetString(0));
				if (_words.ContainsKey(message.GetString(0)) && WordNotOpened(message.GetString(0))) //if word exists and wasn't opened yet
				{
					Console.WriteLine("message.GetString(0): " + message.GetString(0));
					RoomClass.Creator.Send("wc", true, message.GetString(0), message.GetInt(1), message.GetInt(2));
					InsertWord(player.ConnectUserId, message.GetString(0), message.GetInt(1), message.GetInt(2));
				}
				else//response "fail"
				{
					player.Send("wf", message.GetString(0), message.GetInt(1), message.GetInt(2)); //wr - word response
				}
			}
		}

		private void InsertWord(string uid, string word, int rowIndex, int columnIndex)
		{
			Guys[uid].Points += 1;

			var openedWord = new DatabaseObject();
			openedWord.Set("timeSpent", TimePassed());
			openedWord.Set("word", word);
			openedWord.Set("rowIndex", rowIndex);
			openedWord.Set("columnIndex", columnIndex);
			_openedWords.Add(openedWord);

			if (_openedWords.Count == _words.Count) //all words opened
			{
				RoomClass.ScheduleCallback(DoFinish, 1000);
			}
		}

		private bool WordNotOpened(string word)
		{
			var notOpened = true;
			foreach (DatabaseObject wordObj in _openedWords)
			{
				if (wordObj.GetString("word") == word) notOpened = false;
			}
			return notOpened;
		}

		private void DoFinish()
		{
			RoomClass.SaveRecordedWordSeekersGame(RoomClass.ScenarioNumber, _openedWords);
			_gameTimer.Stop(); //so there won't be second "finish" message
		    if (_fruitOpeningTimer != null)
		    {
		        _fruitOpeningTimer.Stop();
		    }
			FinishGame();
		}

		public override void UsePowerup(Player sender, Message message)
		{
		    switch (message.Type)
		    {
		        case "fl":
		        {				
		            var notOpenedWords = new ArrayList();
                    foreach (var word in _words.Keys)
		            {
		                if (WordNotOpened(word)) notOpenedWords.Add(word);
		            }
                    var randomNotOpenedWord = notOpenedWords[Rand.Next(notOpenedWords.Count)].ToString();
		            sender.Send(message.Type, _words[randomNotOpenedWord].RowIndex, _words[randomNotOpenedWord].ColumnIndex);
		        }
		            break;
		        case "rl":
		        {
                    var lettersAmount = 20;
		            var resultIndexes = "";

		            do
		            {
		                var taken = false;
		                var letterRow = Rand.Next(SizeY);
		                var letterColumn = Rand.Next(SizeX);

		                foreach (var word in _words.Keys)
		                {
		                    for (var i = _words[word].RowIndex; i < (_words[word].Horizontal ? _words[word].RowIndex + 1 : _words[word].RowIndex + word.Length); i++) //if word is horizontal only second "for" will be "played"
		                    {
		                        for (var j = _words[word].ColumnIndex; j < (_words[word].Horizontal ? _words[word].ColumnIndex + word.Length : _words[word].ColumnIndex + 1); j++)
		                        {
		                            if (letterRow == i && letterColumn == j)
		                            {
		                                taken = true;
		                            }
		                        }
		                    }
		                }

		                if (taken) continue;
		                lettersAmount--;
		                var end = lettersAmount == 0 ? "" : ",";
		                resultIndexes += letterRow + "," + letterColumn + end;
		                Console.WriteLine("will remove at: " + letterRow + " - " + letterColumn);
		            }
		            while (lettersAmount > 0);
		            sender.Send(message.Type, resultIndexes);
		        }
		            break;
		    }
		}

	    private int TimePassed()
		{
			return (int)(DateTime.UtcNow - new DateTime(1970, 1, 1, 0, 0, 0)).TotalSeconds - _gameStartedAtSeconds;
		}

		private string GetOppID()
		{
			var result = "";
			foreach (var uid in Guys.Keys)
			{
				if (uid != RoomClass.Creator.ConnectUserId) result = uid;
			}
			return result;
		}
	}
}