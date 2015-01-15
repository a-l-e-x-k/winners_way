package  
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.PixelSnapping;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getDefinitionByName;
	import flash.utils.Timer;
	import playerio.PlayerIOError;
	
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class Misc	
	{		
		public static const SNAKE_GAME:String = "snake";
		public static const STACK_UP_GAME:String = "stackUp";
		public static const WORD_SEEKERS_GAME:String = "wordSeekers";		
		public static const GAMES_NAMES:Array = [SNAKE_GAME, STACK_UP_GAME, WORD_SEEKERS_GAME]; 		
		public static const POSSIBLE_COLORS:Array = [0x0000FF, 0xFF0000, 0xFFFF00, 0xFF00FF, 0x66FFFF]; //blue, red, yellow, pink, gayblue, white, black[paid] last 3 - elite (11 total) 0x000001
		public static const STREAK_COLORS:Array = [0xFFFFFF, 0x66FFFF, 0x66FF00, 0xFFFF33, 0xFF9933, 0xFF3300, 0x000000];
		public static const GAME_AREA_WIDTH:int = 774;
		public static const GAME_AREA_HEIGHT:int = 630;
		public static const GAME_AREA_X:int = 0.6;
		public static const GAME_AREA_Y:int = 0.6;
		public static const SHARED_OBJECT_NAME:String = "mystory";
		public static const WINS_TILL_STORY_POPUP:int = 1;
		public static const WINS_TILL_OTHER_GAMES_POPUP:int = 3;
		public static const WINS_TO_UNLOCK_SPIRAL:int = 10;
		public static const WINS_TO_UNLOCK_JACKPOT:int = 40;
		public static const POSSIBLE_GIVEAWAY_ITEMS:Array = ["boost2x", "50coins", "boost3x", "275coins", "10coins", "sevenMines", "100coins", "grid", "250coins", "missile", "975coins", "firstLetter", "75coins", "removeLetters", "10coins", "swapShape", "25coins", "nanoShape", "150coins", "undo", "175coins", "flyingbar", "100coins"]; //all possible things to giveaway. In order. 
		
		public static function setRegistrationPointForSnake(s:Sprite, regx:Number, regy:Number, showRegistration:Boolean = false):void
		{
			//translate movieclip 
			s.transform.matrix = new Matrix(1, 0, 0, 1, -regx, -regy);
			
			//registration point
			if (showRegistration)
			{
				var mark:Sprite = new Sprite();
				mark.graphics.lineStyle(1, 0x000000);
				mark.graphics.moveTo(-5, -5);
				mark.graphics.lineTo(5, 5);
				mark.graphics.moveTo(-5, 5);
				mark.graphics.lineTo(5, -5);
				s.parent.addChild(mark);
			}
		}
		
		public static function definitionExists(definition:String):Boolean
		{
			var exists:Boolean = true;
			try
			{
				getDefinitionByName(definition) as Class;
			}
			catch (e:Error)
			{
				exists = false;
			}
			return exists;
		}
		
		public static function applyColorTransform(mc:MovieClip, color:uint):void
		{
			var colorTransform:ColorTransform = new ColorTransform();		
			colorTransform.color = color;	
			mc.transform.colorTransform = colorTransform;
		}
		
		public static function snapshot(target:DisplayObject, width:int, height:int, transparent:Boolean = false, fillColor:uint = 0xFFFFFF):Bitmap //#302D26 - bd color
		{			
			var bd:BitmapData = new BitmapData(width, height, transparent, fillColor);
			bd.draw(target);			
			return new Bitmap(bd);
		}
		
		public static function snapshotStage():Bitmap
		{
			return snapshot(Networking.client.stage, Misc.GAME_AREA_WIDTH, Misc.GAME_AREA_HEIGHT);
		}
		
		public static function addWatermark(_gameScreen:Bitmap):Bitmap
		{
			var picContainer:MovieClip = new MovieClip();			
			var bitmapToSend:Bitmap = new Bitmap();
			bitmapToSend.bitmapData = _gameScreen.bitmapData.clone();	//gameScreen size is too little	
			picContainer.addChild(bitmapToSend);
			var watermark:MovieClip = new watermarkMC();
			picContainer.addChild(watermark);
			watermark.x = bitmapToSend.width;
			watermark.y = bitmapToSend.height;
			if (Lingvo.dictionary.LANGUAGE == "RUS") watermark.bg.gotoAndStop(2);
			return snapshot(picContainer, picContainer.width, picContainer.height);
		}
		
		public static function randomNumber(limit:int):int
		{
			var randomNumber:int = Math.floor(Math.random() * (limit + 1));
			return randomNumber;
		}		
		
		public static function createRectangle(width:int, height:int, xx:Number, yy:Number):Shape
		{
			var rect:Shape = new Shape(); 
			rect.graphics.beginFill(0x000000);
			rect.graphics.drawRect(0, 0, width, height);
			rect.graphics.endFill();
			rect.x = xx;
			rect.y = yy;
			return rect;
		}
		
		public static function addSimpleButtonListeners(moviebutton:MovieClip):void
		{
			moviebutton.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void { e.currentTarget.gotoAndStop(2); } );
			moviebutton.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void { e.currentTarget.gotoAndStop(1); } );
			moviebutton.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void { e.currentTarget.gotoAndStop(3); } );
		}
		
		public static function getLevelPicture(levelNumber:int):Sprite
        {
            var picture:Sprite;
            if (levelNumber == 1) picture = new bug();
            else if (levelNumber == 2) picture = new flower();
            else if (levelNumber == 3 || levelNumber == 4) picture = new cherry();
            else if (levelNumber == 5 || levelNumber == 6) picture = new balloon();
            else if (levelNumber == 7 || levelNumber == 8) picture = new dirigible();
            else if (levelNumber == 9) picture = new rocket();
            else if (levelNumber == 10) picture = new sun();
            return picture;
        }
		
		public static function delayCallback(func:Function, delay:int):void
		{
			var timer:Timer = new Timer(delay, 1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, function(e:TimerEvent):void
			{
				func();
				timer = null;
			});
			timer.start();
		}
		
		public static function tryRemoveObject(child:DisplayObjectContainer, parent:DisplayObjectContainer):void
		{
			if (child != null && parent.contains(child)) parent.removeChild(child);
			child = null;
		}
		
		public static function handleError(error:PlayerIOError):void 
		{			
			trace(error);
			if (Networking.client != null)
			{
				trace("playerio error");
				trace(error);
				Networking.client.errorLog.writeError(error.name, error.message, error.getStackTrace(), { uid:UserData.id } );
			}
			else Misc.delayCallback(function():void { handleError(error); }, 500);
		}		
		
		public static function getFullGameName(gameName:String):String		
		{
			var fullGameName:String = "";
			switch (gameName) 
			{
				case Misc.SNAKE_GAME:
					fullGameName = '"Snake Battle"';
					break;
				case Misc.STACK_UP_GAME:
					fullGameName = '"Stack Up Battle"';
					break;
				case Misc.WORD_SEEKERS_GAME:
					fullGameName = '"Word Seekers Battle"';
					break;	
			}
			return fullGameName;	
		}
	}
}