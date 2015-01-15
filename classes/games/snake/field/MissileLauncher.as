package games.snake.field 
{
    import events.RequestEvent;

    import flash.display.DisplayObject;
    import flash.utils.Dictionary;
    import flash.utils.getDefinitionByName;

    import games.snake.SnakeData;
    import games.snake.snake.Snake;

    /**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class MissileLauncher extends MovieClipContainer 
	{		
		private var missiles:Dictionary = new Dictionary();
		
		public function MissileLauncher() 
		{
			var assetClass:Class = getDefinitionByName("misslauncher") as Class;
			super(new assetClass(), Math.round((SnakeData.FIELD_WIDTH - 2) / 2) * SnakeData.PART_SIZE, Misc.GAME_AREA_HEIGHT - 40, true);
		}	
		
		public function createMissile(targetSnake:Snake, color:int, targetCellData:Object = null):void
		{
			trace("createMissile");
			_mc.gotoAndStop(1); //is case animation of previous launch ain't finished yet
			
			var missile:Missile = new Missile(_mc.x, _mc.y, targetSnake, color, targetCellData);
			missile.addEventListener(RequestEvent.LAUNCHED, showOpening);
			missile.addEventListener(RequestEvent.IMREADY, showCrazyState);
			missile.addEventListener(RequestEvent.REMOVE_ME, removeMissile);				
			missiles[targetSnake.name] = missile;			
			addChild(missile);
		}
		
		public function tryUpdateMissiles(missileID:String):void
		{
			if (missiles[missileID])
                Missile(missiles[missileID]).updateMissile();
		}
		
		private function showOpening(e:RequestEvent):void
		{
			_mc.gotoAndPlay(1);
		}
		
		private static function showCrazyState(e:RequestEvent):void
		{			
			(e.currentTarget as Missile).targetSnake.goCrazy();
			e.currentTarget.removeEventListener(RequestEvent.IMREADY, showCrazyState);
		}
		
		private function removeMissile(e:RequestEvent):void 
		{			
			trace("removeMissile" + e.currentTarget.name);
			e.currentTarget.removeEventListener(RequestEvent.IMREADY, removeMissile);
			removeChild(e.currentTarget as DisplayObject);
			missiles[e.currentTarget.name] = null;
		}		
	}
}