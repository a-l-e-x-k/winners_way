package lobby.shop.sections 
{
	import com.gskinner.motion.easing.Sine;
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.plugins.MotionBlurPlugin;
	import flash.display.MovieClip;
	import lobby.shop.sections.shelves.infinityShelf.InfinityShelf;
	import lobby.shop.sections.shelves.packsShelf.PacksShelf;
	import lobby.shop.sections.shelves.powerupsShelf.PowerupsShelf;
	/**
	 * Store contains sections (games) which contain shelves
	 * @author Alexey Kuznetsov
	 */
	public class Store extends MovieClipContainer
	{			
		private var _tween:GTween;
		private var _powerupsShelf:PowerupsShelf;
		private var _infinityShelf:InfinityShelf;
		private var _packsShelf:PacksShelf;
		
		public function Store(gameName:String) 
		{
			super(new MovieClip()); //it creates container, to which shelves are added	
			_mc.x = -Misc.GAMES_NAMES.indexOf(gameName) * 750;
			
			this.cacheAsBitmap = true;
			
			MotionBlurPlugin.install();		
			MotionBlurPlugin.enabled = true;							
			MotionBlurPlugin.strength = 0.05;
			
			_powerupsShelf = new PowerupsShelf();
			_infinityShelf = new InfinityShelf();
			_packsShelf = new PacksShelf();
			_mc.addChild(_powerupsShelf); //this one will be moving right-left
			addChild(_infinityShelf);
			addChild(_packsShelf);				
		}		
		
		public function gotoGame(gameName:String):void 
		{
			if (_tween == null || _tween.paused) _tween = new GTween(_mc, 0.5, { x: -Misc.GAMES_NAMES.indexOf(gameName) * 750 }, { ease:Sine.easeOut, autoPlay:true } );		
			else Misc.delayCallback(function() { gotoGame(gameName); }, 100);
		}
	}
}