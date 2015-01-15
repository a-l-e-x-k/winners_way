package lobby.spiral 
{
	import basicPlayerItem.BasicPlayerItem;
	import com.gskinner.motion.easing.Sine;
	import com.gskinner.motion.GTween;
	import events.RequestEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import playerio.DatabaseObject;
	import popups.Popup;
	/**
	 * ...
	 * @author ...
	 */
	public final class LosersSpiral extends Popup
	{
		private const DEFAULT_ITEM_SIZE:int = 60; //60x60px items by default (they get smaller & smaller when u defeat more guys)
		
		private var itemSize:int = 60; 
		private var _nextCells:Array = [];
		private var _field:Array = [];
		private var _itemsInARow:int;
		private var _addItemTimer:Timer;
		
		public function LosersSpiral() 
		{
			super(new myspiral(), 388, 306);
			
			_mc.bg.logo_txt.text = Lingvo.dictionary.myspiral();
			_mc.streakcolors_txt.text = Lingvo.dictionary.streakcolors();
			_mc.andmore_txt.text = Lingvo.dictionary.andmore();
			_mc.loading_mc.message_txt.text = Lingvo.dictionary.loading();
			
			Networking.client.bigDB.load("FullStories", Networking.client.connectUserId, loadSocialData, Misc.handleError);			
		}
		
		private function loadSocialData(myStory:DatabaseObject):void 
		{
			itemSize = myStory.a.length < 81?DEFAULT_ITEM_SIZE:(_mc.bg_mc.width / Math.sqrt(myStory.a.length));
			
			var ids:Array = [];
			for (var i:int = 0; i < myStory.a.length; i++) ids[i] = StoryManager.getCleanName(myStory.a[i]); //cleans names
			
			if (ids.length > 0) //TODO: remove that. Min length is 10 (when user opens spiral)
			{
				createField(myStory.a);
				Networking.socialNetworker.eventDispatcher.addEventListener(RequestEvent.AVATARS_LINKS_LOADED, onAvatarLinksLoaded);		
				Networking.socialNetworker.getAvatarLinks(ids);
			}
		}
		
		private function onAvatarLinksLoaded(e:RequestEvent):void 
		{			
			addAvatarLinks(e.stuff.users); //adds "avalink" property to items in the field
			_mc.removeChild(_mc.loading_mc);
			fillField(e.stuff.users.length);			
			Networking.socialNetworker.eventDispatcher.removeEventListener(RequestEvent.AVATARS_LINKS_LOADED, onAvatarLinksLoaded);
		}
		
		private function createField(storyArray:Array):void 
		{
			_itemsInARow = storyArray.length <= 81?9:Math.ceil(Math.sqrt(storyArray.length)); //ceil - so everything will fit
			_field = new Array(_itemsInARow);
			for (var i:int = 0; i < _itemsInARow; i++) _field[i] = new Array(_itemsInARow);
			
			resetPositions();
			
			_mc.bg_mc.graphics.clear();
			_mc.bg_mc.graphics.lineStyle(2,0xDAE2EE,0.8);
			_mc.bg_mc.alpha = 0;
			
			var lineTween:GTween = new GTween(_mc.bg_mc, 2, { alpha:1 }, { ease:Sine.easeOut } );
			var currentStreak:Array = []; //putting items in a streak here. 
			for (var j:int = 0; j < storyArray.length; j++) 
			{		
				_field[_nextCells[0].j][_nextCells[0].i] = StoryManager.getCleanName(storyArray[j]); //paste name inda cell
				
				if ((storyArray[j].indexOf("-f") != -1 && j > 0)) 
				{
					coloriseStreak(currentStreak);	//if first item in the streak but not the first streak
					currentStreak = [];
				}
				currentStreak.push(StoryManager.getCleanName(storyArray[j]));					
				
				if (j == storyArray.length - 1) coloriseStreak(currentStreak);
				
				if(j > 0) _mc.bg_mc.graphics.lineTo(_nextCells[0].j * itemSize + itemSize / 2, _nextCells[0].i * itemSize + itemSize / 2);							
				_mc.bg_mc.graphics.moveTo(_nextCells[0].j * itemSize + itemSize / 2, _nextCells[0].i * itemSize + itemSize / 2);				
				
				goNext();				
			}			
		}
		
		private function addAvatarLinks(response:Array):void
		{
			for (var i:int = 0; i < response.length; i++) 
			{
				for (var j:int = 0; j < _field.length; j++) 
				{
					for (var k:int = 0; k < _field[j].length; k++) 
					{		
						if (_field[j][k] != null && _field[j][k].namea == response[i].uid.toString())
						{
							_field[j][k] = { namea:_field[j][k].namea, color:_field[j][k].color, avalink:response[i].photo }; //substitute name for name&color object
						}
					}
				} 
			}			
		}	
		
		private function fillField(total:int):void 
		{
			var counter:int = 0;
			_addItemTimer = new Timer(30);
			var myTween:GTween;
				
			_addItemTimer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent) 
			{		
				for (var i:int = 0; i < _nextCells.length; i++) 
				{
					if (!(_field[_nextCells[i].j][_nextCells[i].i] is BasicPlayerItem) && _field[_nextCells[i].j][_nextCells[i].i] != null)
					{
						var item:BasicPlayerItem = new BasicPlayerItem(); //substitute fake one to real one
						item.x = _nextCells[i].j * itemSize;
						item.y = _nextCells[i].i * itemSize;
						item.cacheAsBitmap = true;
						item.name = _field[_nextCells[i].j][_nextCells[i].i].namea;
						item.mc.score_txt.visible = false;
						item.width *= itemSize / DEFAULT_ITEM_SIZE; //because width != height, can't assign width to itemSize
						item.height *= itemSize / DEFAULT_ITEM_SIZE;
						item.createGuy(_field[_nextCells[i].j][_nextCells[i].i].namea, _field[_nextCells[i].j][_nextCells[i].i].color, _field[_nextCells[i].j][_nextCells[i].i].avalink);							
						_mc.bg_mc.addChild(item);
						item.alpha = 0;
						myTween = new GTween(item, total < 1000?1.1 - 0.1 * (total / 100):0.1, { alpha:1}, {ease:Sine.easeIn});
						_field[_nextCells[i].j][_nextCells[i].i] = item; //substitute name for item
						
						trace(i + "  " +  item.name);							
						
						if (counter == total)
						{
							_addItemTimer.stop();								
						}									
						
						counter++;
					}
				}
				goNext(true);					
			});
			_addItemTimer.start();
		}
		
		private function coloriseStreak(streakItems:Array):void
		{
			for (var i:int = 0; i < streakItems.length; i++) 
			{
				for (var j:int = 0; j < _field.length; j++) 
				{
					for (var k:int = 0; k < _field[j].length; k++) 
					{
						if (_field[j][k] == streakItems[i])
						{
							_field[j][k] = { namea:streakItems[i], color:Misc.STREAK_COLORS[streakItems.length - 1] }; //substitute name for name&color object
						}
					}
				} 
			}			
		}
		
		private function goNext(pictures:Boolean = false):void
		{	
			var counter:int = pictures?_nextCells.length:1;
			for (var i:int = 0; i < counter; i++)
			{							
				if (_nextCells[i].dir == "right" && _nextCells[i].j < _itemsInARow-1 && (_field[_nextCells[i].j + 1][_nextCells[i].i] == null || (pictures && !(_field[_nextCells[i].j + 1][_nextCells[i].i] is BasicPlayerItem))))
				{
					_nextCells[i] = { i:_nextCells[i].i, j:_nextCells[i].j + 1, dir:"down"};
				}
				else if (_nextCells[i].dir == "down" && _nextCells[i].i > 0 &&  (_field[_nextCells[i].j][_nextCells[i].i - 1] == null || (pictures && !(_field[_nextCells[i].j][_nextCells[i].i - 1] is BasicPlayerItem))))
				{
					_nextCells[i] = { i:_nextCells[i].i - 1, j:_nextCells[i].j, dir:"left"};
				}
				else if (_nextCells[i].dir == "left" && _nextCells[i].j > 0 && (_field[_nextCells[i].j - 1][_nextCells[i].i] == null || (pictures && !(_field[_nextCells[i].j - 1][_nextCells[i].i] is BasicPlayerItem))))
				{
					_nextCells[i] = { i:_nextCells[i].i, j:_nextCells[i].j - 1, dir:"up"};
				}
				else if (_nextCells[i].dir == "up" && _nextCells[i].i < _itemsInARow-1 && (_field[_nextCells[i].j][_nextCells[i].i + 1] == null || (pictures && !(_field[_nextCells[i].j][_nextCells[i].i + 1] is BasicPlayerItem))))
				{
					_nextCells[i] = { i:_nextCells[i].i + 1, j:_nextCells[i].j, dir:"right"};
				}
				else 
				{
					if (_nextCells[i].dir == "up" && _nextCells[i].j > 0) _nextCells[i].j--;
					else if (_nextCells[i].dir == "right" && _nextCells[i].i < _itemsInARow-1) _nextCells[i].i++;
					else if (_nextCells[i].dir == "down" && _nextCells[i].j < _itemsInARow-1) _nextCells[i].j++;
					else if (_nextCells[i].dir == "left" && _nextCells[i].i > 0) _nextCells[i].i--;	 						
				}
			}
		}		
		
		private function resetPositions():void
		{
			_nextCells = [ { i:Math.floor(_itemsInARow / 2), j:Math.floor(_itemsInARow / 2) - 1, dir:"right" } ];
			if (_itemsInARow > 7)
			{
				_nextCells.push( { i:Math.floor(_itemsInARow / 2), j:Math.floor(_itemsInARow / 2), dir:"down" } );
			}
			if (_itemsInARow > 15)
			{
				_nextCells.push( { i:Math.floor(_itemsInARow / 2) - 1, j:Math.floor(_itemsInARow / 2), dir:"left" }, { i:Math.floor(_itemsInARow / 2) - 1, j:Math.floor(_itemsInARow / 2) - 1, dir:"up" } );
			}			
		}
		
		public function get addItemTimer():Timer {	return _addItemTimer;}
	}
}