package  
{
	import flash.display.MovieClip;
	
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public class MovieClipContainer extends MovieClip 
	{
		protected var _mc:MovieClip;
		
		public function MovieClipContainer(child:MovieClip = null, x:Number = 0, y:Number = 0, attachCoordinatesToMC:Boolean = false)
		{
			_mc = child;		
			addChild(_mc);
			
			if (!attachCoordinatesToMC)
			{
				this.x = x;
				this.y = y;
			}
			else
			{
				_mc.x = x;
				_mc.y = y;
			}		
		}		
		
		public function get mc():MovieClip {return _mc;}
	}
}