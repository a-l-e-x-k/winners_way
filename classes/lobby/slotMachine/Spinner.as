package lobby.slotMachine 
{
    import com.gskinner.motion.GTween;
    import com.gskinner.motion.easing.Circular;
    import com.gskinner.motion.plugins.MotionBlurPlugin;

    import events.RequestEvent;

    import flash.display.MovieClip;
    import flash.display.Shape;
    import flash.utils.getDefinitionByName;

    /**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class Spinner extends MovieClipContainer
	{
		private const TIME_PER_SPIN:int = 4;
		private const ITEM_SIDE_SIZE:int = 55;
		private const SPACE_BETWEEN_ITEMS:int = 15;
		private var _items:Array = [];
		private var _firstLap:GTween; //accelerating till fullSpeed, complete lap
		private var secondLap:GTween;
		
		public function Spinner(typeId:int, i:int, last:Boolean) 
		{
			super(new spinner(), -216 + i * (78 + 5), -52);
			_mc.lock_mc.visible = typeId == -1;

            //dummy symbol export - workaround for Flash SWC incapable of getDefinitionByName for some library items
            coinsWithA; boost2x; boost3x; sevenMines, grid, missile, firstLetter, removeLetters, swapShape, nanoShape; undo; flyingbar;

			if (typeId > -1)
			{
				var realIndex:int = 0;
				
				for (var j:int = -1; j < Misc.POSSIBLE_GIVEAWAY_ITEMS.length * 3; j++)  //if A, B, C, D item: D, A, B, C, D + (A, B, C, D) + (A, B, C, D), etc. 
				{
					if (j < 0) realIndex = j + Misc.POSSIBLE_GIVEAWAY_ITEMS.length;
					else if (j >= Misc.POSSIBLE_GIVEAWAY_ITEMS.length) realIndex = j - Misc.POSSIBLE_GIVEAWAY_ITEMS.length * Math.floor(j / Misc.POSSIBLE_GIVEAWAY_ITEMS.length);
					else realIndex = j;
					
					var assetClass:Class = getDefinitionByName(Misc.POSSIBLE_GIVEAWAY_ITEMS[realIndex].indexOf("coins") == -1 ? Misc.POSSIBLE_GIVEAWAY_ITEMS[realIndex] : "coinsWithA") as Class;
					var pupIcon:MovieClip = new assetClass();
					pupIcon.x = _mc.width / 2 - ITEM_SIDE_SIZE / 2;
					pupIcon.y = ITEM_SIDE_SIZE / 2 + SPACE_BETWEEN_ITEMS + j * (ITEM_SIDE_SIZE + SPACE_BETWEEN_ITEMS);
					_items.push(pupIcon);
					if (Misc.POSSIBLE_GIVEAWAY_ITEMS[realIndex].indexOf("coins") != -1) //item - X amount of coins
					{
						pupIcon.mc.amount_txt.text = Misc.POSSIBLE_GIVEAWAY_ITEMS[realIndex].substring(0, Misc.POSSIBLE_GIVEAWAY_ITEMS[realIndex].indexOf("c"));
					}
					_mc.items_container.con_mc.addChild(pupIcon);
					pupIcon.width *= (ITEM_SIDE_SIZE / pupIcon.height); 
					pupIcon.height *= (ITEM_SIDE_SIZE / pupIcon.height); 						
				}
			}
			
			MotionBlurPlugin.install();		
			MotionBlurPlugin.enabled = true;							
			MotionBlurPlugin.strength = 0.8;
			
			var bottomY:Number = -(ITEM_SIDE_SIZE / 2 + SPACE_BETWEEN_ITEMS + (Misc.POSSIBLE_GIVEAWAY_ITEMS.length - 1) * (ITEM_SIDE_SIZE + SPACE_BETWEEN_ITEMS)) - ITEM_SIDE_SIZE / 2;
			var randomOffset:int = Misc.randomNumber(4) * (ITEM_SIDE_SIZE + SPACE_BETWEEN_ITEMS);
			var fromBottomToTarget:int = (Misc.POSSIBLE_GIVEAWAY_ITEMS.length - typeId) * (ITEM_SIDE_SIZE + SPACE_BETWEEN_ITEMS);
			var lapsSize:int = Misc.POSSIBLE_GIVEAWAY_ITEMS.length * (ITEM_SIDE_SIZE + SPACE_BETWEEN_ITEMS);
			
			_mc.items_container.y = bottomY + fromBottomToTarget - lapsSize * 2 + randomOffset; //lapsSize * 2 means total distance for 2 laps.
			
			_mc.quest_mc.y -= _mc.items_container.y;
			_mc.items_container.addChild(_mc.quest_mc);
			
			var tempMask:MovieClip = new tma();
			var shapeMask:Shape = tempMask.getChildAt(0) as Shape;
			shapeMask.y -= _mc.items_container.y;
			//shapeMask.name = shapeMask;
			_mc.items_container.shmask = shapeMask;
			_mc.items_container.addChild(shapeMask);
			_mc.items_container.con_mc.mask = shapeMask;
			
			secondLap = new GTween(_mc.items_container, TIME_PER_SPIN, { y:bottomY + fromBottomToTarget }, { ease:Circular.easeOut } );
			secondLap.paused = true;
			_firstLap = new GTween(_mc.items_container, TIME_PER_SPIN, { y:bottomY + fromBottomToTarget - lapsSize }, { autoPlay:false, ease:Circular.easeIn, onChange:tryLaunchSecondLap, onInit:removeTempMask, delay: i * 0.7 } );
			
			if (last)
            {
                secondLap.onComplete = function():void {
                    dispatchEvent(new RequestEvent(RequestEvent.REMOVE_ME)); };
            }
		}
		
		private function tryLaunchSecondLap(e:GTween):void 
		{
			if ((TIME_PER_SPIN - _firstLap.position) < 0.1) //launch second tween when less than tenth of a second is left
			{
				_firstLap.end();
				secondLap.paused = false;
				secondLap.position = 0.1;
			}			
		}
		
		public function go():void
		{
			_firstLap.paused = false;			
		}
		
		private function removeTempMask(e:GTween):void
		{
			Misc.delayCallback(function():void
			{
				_mc.quest_mc.visible = false;
				_mc.items_container.con_mc.mask = null;
				_mc.items_container.removeChild(_mc.items_container.shmask);
			}, 1700);
		}
	}
}