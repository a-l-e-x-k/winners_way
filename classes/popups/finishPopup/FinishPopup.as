package popups.finishPopup 
{
	import basicPlayerItem.BasicPlayerItem;
	import caurina.transitions.Tweener;
	import events.RequestEvent;
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import popups.Popup;
	import popups.StatePopup;
	import popups.tutorial.ShowFullStory;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public class FinishPopup extends Popup 
	{				
		private var _gameScreen:Bitmap;
		private var _names:Array = [];
		private var _players:Array = [];
		private var _insnames:Array = [];
		private var _storyPreview:StoryPreview;
		private var _scores:Array = [];
		private var _colors:Array = [];
		private var _photoURLS:Array = [];
		private var _maxScore:int = -1;
		private var _winnerID:String;
		private var _myId:String;
		
		public function FinishPopup(playersS:String, scoresS:String, gameScreen:Bitmap, playersData:Array) 
		{			
			super(new gameFinishPopup(), 393, 328);

			_gameScreen = gameScreen;			
			_players = playersS.split(",");
			_scores = scoresS.split(",");			
			_myId = Networking.client.connectUserId; //use flashVars here
			
			parseUsersData(playersData);
			
			gameScreen.width = _mc.pic_mc.container_mc.width;
			gameScreen.height = _mc.pic_mc.container_mc.height;
			_mc.pic_mc.container_mc.addChild(gameScreen);

            var winnersCount:int = 0; //how many "winners" we have. E.g. 3 players: 10, 10, 5 points. 2 winners. -> nobody won
            for (var i:int = 0; i < _scores.length; i++)
            {
                if (_scores[i] == _maxScore)
                {
                    winnersCount++;
                }
            }

            _storyPreview = new StoryPreview();
            _storyPreview.addEventListener(RequestEvent.SHOW_STREAK_TUTORIAL, showStreakTutorial);
            _mc.container_mc.addChild(_storyPreview);

            var loserMC:BasicPlayerItem = createTwoAvatars();

            if (winnersCount > 1) //everybody won
            {
                typeResultText("equal");
                _storyPreview.showDraw();
            }
            else if (_winnerID == _myId)
            {
                typeResultText("won");

                if(UserData.streak.indexOf(loserMC.name) == -1) UserData.streak.push(loserMC.name);
                if (!StoryManager.checkExistence(_players[_players.indexOf(_winnerID) == 0?1:0]))
                {
                    if(UserData.winCount != -1) UserData.winCount++; //used for jackpot & spiral unlocking
                    _storyPreview.showWin(loserMC, _players[_players.indexOf(_winnerID) == 0?1:0]); //if guy is not inda story already
                    StoryManager.tryNextLevelLoading();
                }
                else
                {
                    _mc.existsalready_txt.text = _names[_players.indexOf(_winnerID) == 0?1:0] + " " + Lingvo.dictionary.existsAlready() + ".";
                    Tweener.addTween(_mc.existsalready_txt, { alpha:1, time:2, delay:0.5, transition:"easeOutSine" } );
                    _storyPreview.showDraw(); //it'll show popup if at streak & will try to add 2nd level picture
                }
            }
            else //lost
            {
                UserData.streak = [];
                typeResultText(_names[_players.indexOf(_winnerID)]);
                _storyPreview.showLoss();
                StoryManager.clearStreak();
            }

            _storyPreview.optimise();

            _mc.userpoints_txt.text = _scores[_players.indexOf(_myId)];
            _mc.opponentpoints_txt.text = _scores[_players.indexOf(_myId) == 0?1:0]; //WARNING! Will work for 2-players mode only

            addButtonListeners();
		}

		private function addButtonListeners():void
		{
			if (Networking.socialNetworker.ACRONYM == Networking.VK)
			{
				_mc.btns.gotoAndStop(2);
				_mc.btns.album_btn.addEventListener(MouseEvent.CLICK, toAlbum);
				_mc.btns.album_btn.addEventListener(MouseEvent.ROLL_OVER, onOver);
				_mc.btns.album_btn.addEventListener(MouseEvent.ROLL_OUT, onOut);
				_mc.btns.album_btn.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
				_mc.btns.album_btn.bg.text_txt.text = Lingvo.dictionary.toalbum();
				
				_mc.btns.post_btn.addEventListener(MouseEvent.CLICK, wallPost);
				_mc.btns.post_btn.bg.text_txt.text = Lingvo.dictionary.postit();
			}
			else //post btn at Facebook adds photo to album
			{
				_mc.btns.post_btn.addEventListener(MouseEvent.CLICK, toAlbum);				
				_mc.btns.post_btn.bg.text_txt.text = Lingvo.dictionary.saveit();
			}
			
			_mc.btns.post_btn.addEventListener(MouseEvent.ROLL_OVER, onOver);
			_mc.btns.post_btn.addEventListener(MouseEvent.ROLL_OUT, onOut);
			_mc.btns.post_btn.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			
			_mc.btns.showFull_btn.addEventListener(MouseEvent.CLICK, showFullStory);
			_mc.btns.showFull_btn.addEventListener(MouseEvent.ROLL_OVER, onOver);
			_mc.btns.showFull_btn.addEventListener(MouseEvent.ROLL_OUT, onOut);
			_mc.btns.showFull_btn.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			_mc.btns.showFull_btn.bg.text_txt.text = Lingvo.dictionary.showfull();
		}
		
		private function parseUsersData(playersData:Array):void 
		{
			for (var i:int = 0; i < _scores.length; i++ )
			{				
				for (var k:int = 0; k < playersData.length; k++) 
				{
					if (playersData[k].id == _players[i])
					{
						_colors.push(playersData[k].color);
						_photoURLS.push(playersData[k].photoURL);
						_names.push(playersData[k].name);
						_insnames.push(playersData[k].insname);
					}
				}
				
				if (_scores[i] > _maxScore) 
				{
					_maxScore = _scores[i];
					_winnerID = _players[i];
				}				
			}			
		}
		
		private function createTwoAvatars():BasicPlayerItem 
		{
			var loserMC:BasicPlayerItem;
			for (var j:int = 0; j < 2; j++) //create 2 pictures (user & opp)
			{
				var fakeMc:MovieClip = _mc.getChildByName("guy_" + j) as MovieClip;
				var guyID:String = j == 0?UserData.id:_players[_players.indexOf(_myId) == 0?1:0];
				var newMC:BasicPlayerItem = new BasicPlayerItem(j == 0); //substitute fake one to real one
				trace("at finish popup creating dude: " + guyID);
				newMC.mc.x = fakeMc.x;
				newMC.mc.y = fakeMc.y;
				newMC.mc.score_txt.visible = false;
				newMC.createGuy(guyID, Misc.POSSIBLE_COLORS[j == 0?_colors[_players.indexOf(_myId)]:_colors[_players.indexOf(_myId) == 0?1:0]], j == 0?UserData.photoURL:_photoURLS[_players.indexOf(_myId) == 0?1:0]); //1st guy - always a user
				if (j == 1) loserMC = newMC;
				_mc.addChild(newMC);
				_mc.removeChild(fakeMc);
			}
			return loserMC;
		}
		
		private static function onDown(e:MouseEvent):void
		{
			e.currentTarget.gotoAndStop("down");
		}
		
		private static function onOver(e:MouseEvent):void
		{
			e.currentTarget.gotoAndPlay("over");
		}
		
		private static function onOut(e:MouseEvent):void
		{
			e.currentTarget.gotoAndStop("up");
		}		
		
		private function toAlbum(e:MouseEvent):void 
		{
			var statePopup:StatePopup = new StatePopup();
			statePopup.uploadingphotos();
			parent.addChild(statePopup);
			
			Networking.socialNetworker.photoUploader.addPhotoToAlbum(Misc.addWatermark(_gameScreen), _insnames[_players.indexOf(UserData.id) == 0?1:0]);
			Networking.socialNetworker.photoUploader.eventDispatcher.addEventListener(RequestEvent.IMREADY, function(e:RequestEvent):void
			{	
				statePopup.superStatus();
				Misc.delayCallback(function():void {	parent.removeChild(statePopup); }, 2000);
			});
			Networking.socialNetworker.photoUploader.eventDispatcher.addEventListener(RequestEvent.ERROR, function(e:RequestEvent):void
			{ 
				statePopup.uploaderror();
				Misc.delayCallback(function():void { parent.removeChild(statePopup); }, 2000);
			});		
			Networking.socialNetworker.photoUploader.eventDispatcher.addEventListener(RequestEvent.PERMISSIONS_GRANTED, function(e:RequestEvent):void //workaround for SecurityError: Error #2176. POST uploading must be initiated by user-generated event
			{ 
				statePopup.permissionsgranted();
				statePopup.showPostButton();
				statePopup.addEventListener(RequestEvent.IMREADY, function(e:RequestEvent):void {
					statePopup.uploadingphotos();
					Networking.socialNetworker.photoUploader.uploadPhoto(); } );
			});
		}
		
		private function wallPost(e:MouseEvent):void 
		{
			var statePopup:StatePopup = new StatePopup(); //it'll show "Loading" 
			parent.addChild(statePopup);
			
			trace(Networking.socialNetworker.wallPoster);
			t.obj(_insnames);
			trace(_gameScreen);
			trace("_players.indexOf(UserData.id): " + _players.indexOf(UserData.id));
			
			Networking.socialNetworker.wallPoster.wallPicturePost(_insnames[_players.indexOf(UserData.id) == 0 ? 1 : 0], Misc.addWatermark(_gameScreen), "");
			Networking.socialNetworker.wallPoster.eventDispatcher.addEventListener(RequestEvent.IMREADY, function(e:RequestEvent):void
			{ 
				statePopup.superStatus();
				Misc.delayCallback(function():void { parent.removeChild(statePopup); }, 2000);
			});
			Networking.socialNetworker.wallPoster.eventDispatcher.addEventListener(RequestEvent.ERROR, function(e:RequestEvent):void
			{ 
				statePopup.uploaderror();
				Misc.delayCallback(function():void { parent.removeChild(statePopup); }, 2000);
			});
		}
		
		private function typeResultText(result:String):void		
		{
			if (result == "equal")
                _mc.result_txt.text = Lingvo.dictionary.everywon();
			else if (result == "won")
			{
				_mc.result_txt.text = Lingvo.dictionary.youwon();
				_mc.logo.balloons_mc.alpha = 100;
			}
			else
                _mc.result_txt.text = result + " " + Lingvo.dictionary.wongame(); //result here is dude's name
		}
		
		private function showStreakTutorial(e:RequestEvent):void
		{
			var showFullStoryPopup:ShowFullStory = new ShowFullStory( -this.x, -this.y);
			addChild(showFullStoryPopup);
		}
		
		private function showFullStory(e:MouseEvent):void 
		{
			_storyPreview.clean();
			dispatchEvent(new RequestEvent(RequestEvent.REMOVE_ME, {showFullStory:true}, false));
		}
		
		override public function dispatchRemove(e:Event = null):void
		{
			_screenshot.bitmapData.dispose();
			_storyPreview.clean();
			dispatchEvent(new RequestEvent(RequestEvent.REMOVE_ME, {}, false));
		}
	}
}