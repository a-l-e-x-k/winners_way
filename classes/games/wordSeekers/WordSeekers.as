package games.wordSeekers 
{
    import events.RequestEvent;

    import games.Game;
    import games.gameUI.PlayerItem;
    import games.wordSeekers.field.Field;

    import playerio.Connection;
    import playerio.DatabaseObject;
    import playerio.Message;

    import popups.tutorial.WordSeekersTutorial;

    /**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class WordSeekers extends Game
	{
		private var _field:Field;
		private var _words:Array = [];
		private var _wordsData:Array = [];
		private var _myID:String;
		private var _oppID:String;
		private var _fieldRows:Array;
		
		public function WordSeekers(connection:Connection, gameName:String) 
		{
			_gameLength = 60 * 1000; 
			super(connection, gameName);
			_connection.addMessageHandler("wc", onWordCorrect);
			_connection.addMessageHandler("wf", onWordFail);
			_connection.addMessageHandler("fl", showFirstLetter);
			_connection.addMessageHandler("rl", removeLetters);
			
			_myID = UserData.id;
			_gameDataReady = false;
			
			Networking.socialNetworker.publishPlayedGameAction(Misc.WORD_SEEKERS_GAME);
		}
		
		override protected function loadWordsData(scenarioID:int):void
		{
			Networking.client.bigDB.load("WordsScenarios", scenarioID.toString(), onScenariosLoaded, Misc.handleError);
		}
		
		private function onScenariosLoaded(gameObj:DatabaseObject):void 
		{
			_fieldRows = gameObj.field;
			_wordsData = gameObj.words; //full data about words at scenario. Coordinated are also here. Happy cheating :)
			_gameDataReady = true;
			trySendReady();
		}
		
		private function removeLetters(message:Message):void 
		{
			_field.removeLetters(message.getString(0));
		}
		
		private function showFirstLetter(message:Message):void 
		{
			_field.showFirstLetter(message.getInt(0), message.getInt(1));
		}
		
		override protected function startGame(message:Message):void
		{
			for each (var item:Object in _users) if (item.id != _myID) _oppID = item.id;
			var rows:Array = [];
			for (var i:int = 0; i < _fieldRows.length; i++)
			{
				rows[i] = [];
				for (var j:int = 0; j < (_fieldRows[i] as Array).length; j++) 
				{
					rows[i][j] = (_fieldRows[i] as Array)[j];
				}				
			}
			
			for (var k:int = 0; k < _wordsData.length; k++) _words.push(_wordsData[k].word);
			
			_field = new Field(rows);
			_field.addEventListener(RequestEvent.SEND_WORD_SELECTED, sendWordSelected);
			_field.showWords(_words);
			addChild(_field);			
			
			if (!UserData.openedWordSeekers)
			{
				var tut:WordSeekersTutorial = new WordSeekersTutorial(0, 0);
				_field.addEventListener(RequestEvent.SEND_WORD_SELECTED, function(e:RequestEvent):void {
                    if (contains(tut)) removeChild(tut);
                });
				addChild(tut);
				
				Networking.socialNetworker.publishFirstGame(Misc.WORD_SEEKERS_GAME, getOppName()); //FB pubishes "I started playing Snake Battle game at Winner's Way."
			}
		}
		
		override protected function finishGame(message:Message, jackpotWin:Boolean = false):void
		{
			_connection.removeMessageHandler("wc", onWordCorrect);
			_connection.removeMessageHandler("wf", onWordFail);
			_connection.removeMessageHandler("fl", showFirstLetter);
			_connection.removeMessageHandler("rl", removeLetters);
			_field.mc.words_txt.visible = false;
			_field.finishAnimations();			
			
			if (!UserData.openedWordSeekers) //tutorial was shown already, it's just a property. Deselecting "flower" (цветок)
			{
				UserData.openedWordSeekers = true;
				_field.forceReset(Lingvo.dictionary.flower(), 4, 8);
			}			
			
			_lastScreenshot = Misc.snapshot(_field, Misc.GAME_AREA_WIDTH, Misc.GAME_AREA_HEIGHT);			
			createFinishGamePopup(message, jackpotWin);
			removeChild(_field);
		}		
		
		override protected function usePowerup(e:RequestEvent):void
		{
			if (e.stuff.name == "firstLetter") _connection.send("fl");
			else if (e.stuff.name == "removeLetters") _connection.send("rl");
		}
		
		private function onWordCorrect(message:Message):void 
		{
			trace(message);
			var selectedBy:String = message.getBoolean(0) ? _myID : _oppID;
			
			var color:uint = (_gameUI.getChildByName(selectedBy) as PlayerItem).color;		
			_field.showWordResult(message.getString(1), message.getInt(2), message.getInt(3), color);
			(_gameUI.getChildByName(selectedBy) as PlayerItem).changePoints(1);
			
			removeWordFromHints(message.getString(1));
		}

        private function removeWordFromHints(word:String):void
        {
            for each (var item:String in _words)
            {
                if (word == item)
                {
                    _words.splice(_words.indexOf(item), 1);
                    _field.showWords(_words);
                    break;
                }
            }
        }
		
		private function onWordFail(message:Message):void 
		{
			_field.showWordResult(message.getString(0), message.getInt(1), message.getInt(2));
		}
		
		private function sendWordSelected(e:RequestEvent):void 
		{			
			trace("UserData.openedWordSeekers: " + UserData.openedWordSeekers);
			if (e.stuff.name != "flower" && e.stuff.name != "цветок")
                _connection.send("ws", e.stuff.name, e.stuff.j, e.stuff.m); //ws - word selected
			else if (!UserData.openedWordSeekers)
			{
				_field.showWordResult(e.stuff.name, e.stuff.j, e.stuff.m, (_gameUI.getChildByName(Networking.client.connectUserId.toString()) as PlayerItem).color);
				(_gameUI.getChildByName(Networking.client.connectUserId.toString()) as PlayerItem).changePoints(1);
                removeWordFromHints(e.stuff.name);
			}
			else if (UserData.openedWordSeekers) //selecting flower when completed tutorial
			{
				_field.showWordResult(Lingvo.dictionary.flower(), 8, 4);
			}
		}
	}
}