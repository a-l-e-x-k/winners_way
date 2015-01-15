package basicPlayerItem 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public class BasicPlayerItemBg extends Sprite
	{
		protected var _mc:Sprite;
		public function BasicPlayerItemBg()
		{
			_mc = new playerItemMC() as Sprite;
			_mc.x = 9;
			_mc.y = 7;
			addChild(_mc);
		}
		public function get mc():MovieClip {return _mc as MovieClip;}
	}
}