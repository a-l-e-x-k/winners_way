package games.wordSeekers.field 
{
	import events.RequestEvent;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.utils.getDefinitionByName;
	
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class Field extends MovieClipContainer
	{
		private const sizeX:int = 15;
		private const sizeY:int = 12;
		
		private var _mouseDown:Boolean;
		private var _currentWord:String = "";
		private var _firstLetter:Object;
		private var _lastLetter:Object;		
		private var _rows:Array = [];
		private var _letters:Array = [];
		
		public function Field(rows:Array) 
		{			
			_rows = rows;
			
			var assetClass:Class =  getDefinitionByName("field") as Class;
			super(new assetClass(), 90, 75, true);
			
			for (var j:int = 0; j < sizeY; j++) //rows
			{
				_letters[j] = [];
				for (var m:int = 0; m < sizeX; m++) //columns
				{
					var letter:MovieClip = new Letter(j, m, _rows[j][m]);
					letter.name = _rows[j][m];
					letter.addEventListener(MouseEvent.ROLL_OVER, onOver);
					letter.addEventListener(MouseEvent.ROLL_OUT, onOut);
					letter.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
					addEventListener(MouseEvent.MOUSE_UP, onUp);
					_mc.addChild(letter);
					_letters[j][m] = letter;
				}
			}				
		}
		
		public function showWordResult(word:String, j:int, m:int, color:uint = 0x000000):void 
		{
			trace("showWordResult: " + " word: " + word + " j: " + j + " m: " + m + " color: " + color);
			var horizontal:Boolean = _letters[j][m + 1].name == word.charAt(1) && _letters[j][m + 2].name == word.charAt(2); //3-letters check. all words must be at least 3-letters long
			if (horizontal)
			{
				for (var i:int = 0; i < word.length; i++ )
				{
					if (color == 0)
                        _letters[j][m + i].showFail();
					else
                        _letters[j][m + i].showWin(color);
				}
			}
			else
			{
				for (i = 0; i < word.length; i++ )
				{
					if (color == 0)
                        _letters[j + i][m].showFail();
					else
                        _letters[j + i][m].showWin(color);
				}
			}
			if (color == 0 && SoundManager.soundsOn) SoundManager.sounds["wrong"].play();
		}
		
		public function showWords(words:Array):void
		{
			var text:String = Lingvo.dictionary.wtf();
			for each (var word:String in words)
			{
				text += word + (words.indexOf(word) != words.length - 1 ? ", " : ".");
			}
			_mc.words_txt.text = text;
		}
		
		public function forceReset(word:String, j:int, m:int):void //reset "flower word"
		{
			for (var i:int = 0; i < word.length; i++ )
			{
				_letters[j][m + i].forceReset();
			}
		}
		
		public function showFirstLetter(row:int, column:int):void
		{
			_letters[row][column].showYourself();
		}
		
		public function removeLetters(indexes:String):void
		{
			var indexArr:Array = indexes.split(",");
			var rowIndex:int = 0;
			for (var i:int = 0; i < indexArr.length; i++) 
			{
				if (i % 2 == 0) //row index
				{
					rowIndex = int(indexArr[i]);
				}
				else //column index
				{
					trace("removing: " + rowIndex + " colIndex: " + int(indexArr[i]));
					_letters[rowIndex][int(indexArr[i])].goInvisible();
				}
			}			
		}
		
		public function finishAnimations():void
		{
			for (var j:int = 0; j < sizeY; j++) //rows
			{
				for (var m:int = 0; m < sizeX; m++) //columns
				{
					_letters[j][m].finishAnimation();			
				}
			}	
		}
		
		private function onUp(e:MouseEvent):void 
		{		
			if (e.currentTarget is Letter)
			{
				if (_mouseDown) e.currentTarget.mc.gotoAndStop(3);
				else	e.currentTarget.mc.gotoAndStop(2);			
			}
			_mouseDown = false;
			if (_currentWord.length > 2)
			{
				dispatchEvent(new RequestEvent(RequestEvent.SEND_WORD_SELECTED, {name:_currentWord, j:_firstLetter.j, m:_firstLetter.m}));				
			}
			else  //reset all btns
			{
				for (var j:int = 0; j < sizeY; j++) //rows
				{
					for (var m:int = 0; m < sizeX; m++) //columns
					{
						if (!_letters[j][m].opened)
						{
							_letters[j][m].selected = false;
							_letters[j][m].mc.gotoAndStop(1); //reset all btns
						}
					}
				}		
			}
		}
		
		private function onDown(e:MouseEvent):void 
		{
			for (var j:int = 0; j < sizeY; j++) //rows
			{
				for (var m:int = 0; m < sizeX; m++) //columns
				{
					if (!_letters[j][m].opened)
					{
						_letters[j][m].selected = false;
						_letters[j][m].mc.gotoAndStop(1); //reset all btns
						if (_letters[j][m] == e.currentTarget)
						{
							_firstLetter = _lastLetter = { j:j, m:m };
							_letters[j][m].selected = true;
						}				
					}						
				}
			}		
			
			_mouseDown = true;
			e.currentTarget.mc.gotoAndStop(3);
			_currentWord = e.currentTarget.name;
		}
		
		private function onOut(e:MouseEvent):void 
		{
			if (!_mouseDown && !e.currentTarget.selected && !e.currentTarget.opened) e.currentTarget.mc.gotoAndStop(1); //if mouse is UP (not selecting word now && letter was not selected yet)
		}
		
		private function onOver(e:MouseEvent):void 
		{ 
			if (e.currentTarget.mc.currentFrame == 1 && !e.currentTarget.opened)
			{
				if (_mouseDown) 
				{					
					if ((((_firstLetter.j == _lastLetter.j) && _firstLetter.j == e.currentTarget.j) ||((_firstLetter.m == _lastLetter.m) && _firstLetter.m == e.currentTarget.m)) && (e.currentTarget.j - _lastLetter.j == 1 || e.currentTarget.m - _lastLetter.m == 1)) //if horiz/diag && 1 by 1
					{
						_lastLetter = { j:e.currentTarget.j, m:e.currentTarget.m };
						_currentWord += e.currentTarget.name;
						e.currentTarget.mc.gotoAndStop(3);
						e.currentTarget.selected = true;
					}				
				}
				else
				{
					e.currentTarget.mc.gotoAndStop(2);
				}
			}			
		}	
	}
}