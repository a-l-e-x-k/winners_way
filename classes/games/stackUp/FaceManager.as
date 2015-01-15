package games.stackUp 
{
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class FaceManager 
	{
		private var _shapes:Array;
		private var _playTimer:Timer;
		
		public function FaceManager(faces:Array) 
		{
			_shapes = faces;
			
			createRandomTimer();
		}
		
		public function stopTimer():void
		{
			_playTimer.stop();
		}
		
		private function createRandomTimer():void 
		{
			_playTimer = new Timer(700 + (Misc.randomNumber(10000) / (_shapes.length > 0 ? _shapes.length : 1)), 1);
			_playTimer.addEventListener(TimerEvent.TIMER_COMPLETE, playRandomShape);
			_playTimer.start();
		}
		
		private function playRandomShape(e:TimerEvent):void 
		{
			if (_shapes.length > 0)
			{
				var playableShapes:Array = new Array();
				for each (var shape:MovieClip in _shapes) 
				{
					if (shape.playable_mc != null)
					{
						playableShapes.push(shape);
					}
				}
				//
				//trace("_shapes.length: " + _shapes.length);
				//trace("playableShapes.length: " + playableShapes.length);
				
				if (playableShapes.length > 0)
				{
					playableShapes[Misc.randomNumber(playableShapes.length - 1)].playable_mc.play();
				}
			}
			
			createRandomTimer();
		}	
	}
}