package games.gameUI 
{
	import flash.display.Shape;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class TimeMask extends Sprite
	{		
		private const degChange:Number = 1; // Amount angle will change on each click		
		private const circleR:Number = 60; // Circle radius (in pixels)
		private var circle:Shape;
		
		public function TimeMask(xx:Number, yy:Number) 
		{
			this.x = xx;
			this.y = yy;			
			
			circle = new Shape();
			circle.graphics.moveTo(0,0);
			circle.graphics.lineTo(circleR,0);			
			
			addChild(circle);		
			updatePicture(0);
		}
		
		public function updatePicture(degree:Number, lifetime:Boolean = false):void 
		{	
			var radianAngle:Number = degree*Math.PI/180.0; 
			var i:int;
			
			circle.graphics.clear();							
			circle.graphics.moveTo(0,0);
			circle.graphics.beginFill(lifetime?0xFFFFFF:0x000000, 0.75);
			
			for (i = 0; i <= Math.abs(degree); i++) 
			{
				circle.graphics.lineTo(circleR*Math.cos(i*Math.PI/180), -circleR*Math.sin(i*Math.PI/180));		
			}
			
			circle.graphics.lineTo(0,0);
			circle.graphics.endFill();
		}
		
	}

}