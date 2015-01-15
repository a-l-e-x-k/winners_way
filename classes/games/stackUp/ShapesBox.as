package games.stackUp 
{
	import flash.display.MovieClip;
	import flash.utils.getDefinitionByName;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class ShapesBox extends MovieClipContainer
	{	
		private var _currentShape:MovieClip;
		
		public function ShapesBox() 
		{
			var assetClass:Class = getDefinitionByName("shapesBox") as Class;
			super(new assetClass(), 12, 70, true);
			
			_mc.mc.drag_txt.text = Lingvo.dictionary.dragme();
		}
		
		public function createShape(staticShape:MovieClip, type:int):void 
		{
			if (_currentShape != null && contains(_currentShape))
			{
				var lastx:Number = _currentShape.x;
				var lasty:Number = _currentShape.y;
				removeChild(_currentShape);
				
				_currentShape = staticShape;	
				setShapeCoordinates(lastx, lasty);
			}
			else 
			{
				_currentShape = staticShape;
				setShapeCoordinates(_mc.width / 2 + _mc.x, _mc.height / 2 + _mc.y);
			}
			
			_currentShape.cacheAsBitmap = true;
			_currentShape.name = type.toString();
			_currentShape.alpha = 70;
			addChild(_currentShape);
		}
		
		private function setShapeCoordinates(xx:Number, yy:Number):void
		{
			_currentShape.x = xx;
			_currentShape.y = yy;
		}
		
		public function removeShape():void
		{			
			_currentShape = null;			
		}
		
		public function get currentShape():MovieClip {	return _currentShape;	}
		
	}

}