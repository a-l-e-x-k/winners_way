package lobby.friends
{
    import events.RequestEvent;

    import flash.display.Shape;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.events.TimerEvent;
    import flash.geom.Rectangle;
    import flash.utils.Timer;

    import playerio.DatabaseObject;

    import caurina.transitions.Tweener;

    /**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class FriendPanel extends MovieClipContainer
	{
		private const SLOTS_AMOUNT:int = 50;
		private var _items:Array = [];
		private var _friendsState:Boolean = false;
		private var _itemsContainer:Sprite;
		private var _newTimer:Timer;
		private var _bounds:Rectangle;
		private var _scrolling:Boolean;
		private var _mask:Shape;
		private var _callbackFinished:Boolean = true;
		private var _friendsShown:Array = [];
		
		public function FriendPanel()
		{
			super(new friends(), 4, 525);
			
			_mc.friends_btn.addEventListener(MouseEvent.CLICK, switchState);
			_mc.top_btn.addEventListener(MouseEvent.CLICK, switchState);
			_mc.friends_btn.addEventListener(MouseEvent.ROLL_OVER, onOver);
			_mc.top_btn.addEventListener(MouseEvent.ROLL_OVER, onOver);
			_mc.friends_btn.addEventListener(MouseEvent.ROLL_OUT, onOut);
			_mc.top_btn.addEventListener(MouseEvent.ROLL_OUT, onOut);
			_mc.friends_btn.buttonMode = true;
			_mc.top_btn.buttonMode = true;
			_mc.friends_btn.btn.text_txt.text = Lingvo.dictionary.friends();
			_mc.top_btn.btn.text_txt.text = Lingvo.dictionary.toplabel();
			
			_mask = Misc.createRectangle(630, 88, 153, 0);
			addChild(_mask);
			
			_itemsContainer = new Sprite();
			_itemsContainer.x = 153;
			_itemsContainer.y = 5;
			_itemsContainer.mask = _mask;
			addChild(_itemsContainer);
			
			switchState();
			
			addEventListener(Event.ENTER_FRAME, tryScroll);
			
			_bounds = new Rectangle(_mc.scroll_mc.bar_mc.x, _mc.scroll_mc.scroller_mc.y, _mc.scroll_mc.bar_mc.width, 0);
			
			_mc.scroll_mc.scroller_mc.addEventListener(MouseEvent.MOUSE_DOWN, startScroll);
			Networking.client.stage.addEventListener(MouseEvent.MOUSE_UP, stopScroll);
		}
		
		private static function onOut(e:MouseEvent):void
		{
			if (e.currentTarget.currentFrameLabel != "down" || e.currentTarget.name == "help_btn") e.currentTarget.gotoAndStop("up");				
		}
		
		private static function onOver(e:MouseEvent):void
		{
			if (e.currentTarget.currentFrameLabel != "down") e.currentTarget.gotoAndPlay("over");				
		}
		
		private function startScroll(e:Event):void
		{
			_scrolling = true;
			_mc.scroll_mc.scroller_mc.startDrag(false, _bounds);
		}
		
		private function stopScroll(e:Event):void
		{
			_scrolling = false;
			_mc.scroll_mc.scroller_mc.stopDrag();
		}
		
		private function tryScroll(e:Event):void
		{
			if (_scrolling)	_itemsContainer.x = _mask.x - (_mc.scroll_mc.scroller_mc.x / _mc.scroll_mc.bar_mc.width) * (_itemsContainer.width - _mc.scroll_mc.bar_mc.width);
			_mc.scroll_mc.scroller_mc.x = ((_mask.x - _itemsContainer.x) / (_itemsContainer.width - _mc.scroll_mc.bar_mc.width)) * _mc.scroll_mc.bar_mc.width;
		}
		
		private function switchState(e:MouseEvent = null):void
		{
            trace("Trying to switch state: _callbackFinished: "  + _callbackFinished);
			if (_callbackFinished)
			{
				if (e == null || ((e.currentTarget == _mc.top_btn && _friendsState) || (e.currentTarget == _mc.friends_btn && !_friendsState)))
				{
					_friendsState = !_friendsState;
					
					if (_friendsState)
					{
						_mc.top_btn.buttonMode = true;
						_mc.top_btn.gotoAndStop("up");
						_mc.friends_btn.buttonMode = false;
						_mc.friends_btn.gotoAndStop("down");
					}
					else
					{
						_mc.friends_btn.buttonMode = true;
						_mc.friends_btn.gotoAndStop("up");
						_mc.top_btn.buttonMode = false;
						_mc.top_btn.gotoAndStop("down");
					}
					
					_mc.scroll_mc.scroller_mc.x = 0;
					_itemsContainer.x = _mask.x;
					
					removeItems();

                    _callbackFinished = false;

					if (!_friendsState)
                        loadTop();
					else
                        loadFriends();
				}
			}
		}
		
		private function loadFriends():void
		{
			if (UserData.friends == null)
                Misc.delayCallback(loadFriends, 70); //loading friends only once by Networker at gameStart
			else
                selectFriendsToShow();
		}
		
		private function selectFriendsToShow():void 
		{	
			_friendsShown = [];
			var usedIDS:Array = [];
			
			for each (var friend:Object in UserData.friends) 
			{
				if (friend.inApp)
				{
					if (_friendsShown.length < SLOTS_AMOUNT) 
					{
						_friendsShown.push(friend);
						usedIDS.push(friend.id);
					}
					else break; //max 50 users (even in-app)
				}
			}
			
			if (_friendsShown.length < SLOTS_AMOUNT) //there are less than 50 in app friends 
			{
				var slotsLeft:int = (UserData.friends.length < SLOTS_AMOUNT ? UserData.friends.length : SLOTS_AMOUNT) - _friendsShown.length; //if < 50 friends there will be less than 50 slots
				var randomIndex:int;
				
				for (var i:int = 0; i < slotsLeft; i++) 
				{
					do randomIndex = Misc.randomNumber(UserData.friends.length - 1); //select random friend from all friends		
					while (usedIDS.indexOf(UserData.friends[randomIndex].id) != -1); //select another dude if this one was already added to a slot
					
					usedIDS.push(UserData.friends[randomIndex].id);
					_friendsShown.push(UserData.friends[randomIndex]); //add selected random guy to the slot
				}
			}

            Tweener.addTween(_mc.loading_mc, { alpha:0, time:0.3, transition:"easeOutExpo" } );

            if(_friendsShown.length > 0)
			    startItemCreation();
            else
                _callbackFinished = true;
		}
		
		private function startItemCreation():void
		{
			trace("startItemCreation");			
			
			_newTimer = new Timer(40, _friendsShown.length); //for CPU-easy
			_newTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function(e:TimerEvent):void { _callbackFinished = true; } );
			_newTimer.addEventListener(TimerEvent.TIMER, function(e:Event):void
			{
				createItem(_friendsShown[_items.length].name, _friendsShown[_items.length].id, -1, 0, _friendsShown[_items.length].photoURL, _friendsShown[_items.length].inApp);
			});
			_newTimer.start();
		}
		
		private function createItem(name:String = "", id:String = "", count:int = -1, level:int = 0, pictureURL:String = "", inApp:Boolean = false):void
		{
			var newItem:FriendItem = new FriendItem(_items.length, name, id, count, level, pictureURL, inApp);
			newItem.y = 100;
			_items.push(newItem);
			_itemsContainer.addChild(newItem);
			Tweener.addTween(newItem, {y: 0, time: 0.7, transition: "easeOutExpo"});
		}
		
		private function loadTop():void
		{
			Tweener.addTween(_mc.loading_mc, { alpha:1, time:1, transition:"easeOutExpo" } );
			Networking.client.bigDB.load("Top", "g", function(dbObj:DatabaseObject):void
			{
				var toLoad:Array = [];
				for (var i:int = 0; i < dbObj.g.length; i++) 
				{
					if (dbObj.g[i].id != 0)
                        toLoad.push(dbObj.g[i].id);
				}
				
				var func:Function;		
				Networking.socialNetworker.eventDispatcher.addEventListener(RequestEvent.USERS_INFO_LOADED, func = function(e:RequestEvent):void
				{ 
					Networking.socialNetworker.eventDispatcher.removeEventListener(RequestEvent.USERS_INFO_LOADED, func);
					getDetailedTopInfo(e.stuff.users, dbObj.g) 
				});				
				Networking.socialNetworker.getUsersNamesAndPhotos(toLoad);
			}, Misc.handleError);
		}
		
		private function getDetailedTopInfo(users:Array, top:Array):void 
		{
			Tweener.addTween(_mc.loading_mc, { alpha:0, time:0.3, transition:"easeOutExpo" } );
			
			var playerCount:int = 0;
			var playerLevel:int = 0;
			_newTimer = new Timer(40, users.length); //for CPU-easy 
			_newTimer.addEventListener(TimerEvent.TIMER_COMPLETE, function(e:TimerEvent):void { _callbackFinished = true; } );
			_newTimer.addEventListener(TimerEvent.TIMER, function(ev:Event):void
			{
				for (var j:int = 0; j < users.length; j++) 
				{
					if (top[_newTimer.currentCount - 1].id == users[j].id)
					{
						playerCount = top[_newTimer.currentCount - 1].c;
						playerLevel = top[_newTimer.currentCount - 1].lvl;
						createItem(users[j].name, users[j].id, playerCount, playerLevel, users[j].photoURL);
						return; //1 guy per tick
					}
				}				
			});
			_newTimer.start();	
		}
		
		private function removeItems():void
		{
			if (_newTimer != null)
			{
				_newTimer.reset();
				_newTimer.removeEventListener(TimerEvent.TIMER, function():void{	});
			}
			
			var co:int = _itemsContainer.numChildren;
			for (var i:int = 0; i < co; i++)
			{
				_itemsContainer.removeChild(_itemsContainer.getChildAt(0));
				_items.shift();
			}
		}
	}
}