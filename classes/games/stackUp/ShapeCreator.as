package games.stackUp 
{
	import com.actionsnippet.qbox.QuickBox2D;
	import com.actionsnippet.qbox.QuickObject;
	import flash.display.MovieClip;
	import flash.utils.getDefinitionByName;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class ShapeCreator 
	{		
		public static function getSkinByType(skinType:int):Class
		{
			var assetClass:Class; // 0 - 8 - basic shapes
			
			//*****Basic*****
			if (skinType == 0)      assetClass = getDefinitionByName("hexahedron") as Class;
			else if (skinType == 1) assetClass = getDefinitionByName("pentagon") as Class;
			else if (skinType == 2) assetClass = getDefinitionByName("stick") as Class;
			else if (skinType == 3) assetClass = getDefinitionByName("rectangleGay") as Class;
			else if (skinType == 4) assetClass = getDefinitionByName("rectangleGreen") as Class;
			else if (skinType == 5)	assetClass = getDefinitionByName("rectangleSlim") as Class;
			else if (skinType == 6) assetClass = getDefinitionByName("square") as Class;
			else if (skinType == 7) assetClass = getDefinitionByName("star") as Class;
			else if (skinType == 8) assetClass = getDefinitionByName("triangle") as Class;
			else if (skinType == 9) assetClass = getDefinitionByName("cryingGreen") as Class;
			else if (skinType == 10) assetClass = getDefinitionByName("horizBandit") as Class;
			else if (skinType == 11) assetClass = getDefinitionByName("squareEye") as Class;
			else if (skinType == 12) assetClass = getDefinitionByName("freezingTria") as Class;
			else if (skinType == 13) assetClass = getDefinitionByName("heptahedron") as Class;
			else if (skinType == 14) assetClass = getDefinitionByName("parallelogram") as Class;
			else if (skinType == 15) assetClass = getDefinitionByName("pinkTriangle") as Class;
			
			//*****Sea******			
			else if (skinType == 20) assetClass = getDefinitionByName("crab") as Class;
			else if (skinType == 21) assetClass = getDefinitionByName("greenfish") as Class;
			else if (skinType == 22) assetClass = getDefinitionByName("hedgehog") as Class;
			else if (skinType == 23) assetClass = getDefinitionByName("hippocampus") as Class;
			else if (skinType == 24) assetClass = getDefinitionByName("seashell") as Class;
			else if (skinType == 25) assetClass = getDefinitionByName("triangleFish") as Class;
			
			//*****Beach*****
			else if (skinType == 40) assetClass = getDefinitionByName("bag") as Class;
			else if (skinType == 41) assetClass = getDefinitionByName("ball") as Class;
			else if (skinType == 42) assetClass = getDefinitionByName("mattress") as Class;
			else if (skinType == 43) assetClass = getDefinitionByName("phone") as Class;
			else if (skinType == 44) assetClass = getDefinitionByName("swimming_circle") as Class;
			else if (skinType == 45) assetClass = getDefinitionByName("tanner") as Class;
			
			//*****Basic New Year*****
			if (skinType == 60)      assetClass = getDefinitionByName("ny_hexahedron") as Class;
			else if (skinType == 61) assetClass = getDefinitionByName("ny_pentagon") as Class;
			else if (skinType == 62) assetClass = getDefinitionByName("ny_stick") as Class;
			else if (skinType == 63) assetClass = getDefinitionByName("ny_rectangleGay") as Class;
			else if (skinType == 64) assetClass = getDefinitionByName("ny_rectangleGreen") as Class;
			else if (skinType == 65) assetClass = getDefinitionByName("ny_rectangleSlim") as Class;
			else if (skinType == 66) assetClass = getDefinitionByName("ny_square") as Class;
			else if (skinType == 67) assetClass = getDefinitionByName("ny_star") as Class;
			else if (skinType == 68) assetClass = getDefinitionByName("ny_triangle") as Class;
			else if (skinType == 69) assetClass = getDefinitionByName("wreath") as Class;
			else if (skinType == 70) assetClass = getDefinitionByName("rural") as Class;
			
			//****Powerups****
			else if (skinType == 777) assetClass = getDefinitionByName("nano") as Class;
			else if (skinType == 888) assetClass = getDefinitionByName("bar") as Class;
			return assetClass;
		}
		
		public static function addShape(skin:MovieClip, sim:QuickBox2D, worldMc:World):QuickObject
		{
			var shapeObj:QuickObject;
			
			skin.x -= worldMc.mc.x;
			skin.y -= worldMc.mc.y;
			
			//fixes 4 coordinates (when skin is moved from 0.0-coordinates -> here, in mc, which coordinates are not 0-0).
			if (skin.x < 0) skin.x = skin.width;
			if (skin.x > Misc.GAME_AREA_WIDTH) skin.x = Misc.GAME_AREA_WIDTH - skin.width; //worldWidth
			if (skin.y > Misc.GAME_AREA_HEIGHT) skin.y = Misc.GAME_AREA_HEIGHT - skin.height; //worldHeight 
			
			var skinType:String = skin.name;
			if (skinType == "2" || skinType == "3" || skinType == "4" || skinType == "5" || skinType == "6" || skinType == "9" || skinType == "10" || skinType == "11" || skinType == "42" || skinType == "43" || skinType == "62" || skinType == "63"  || skinType == "64"  || skinType == "65"  || skinType == "66") //rectangles
			{
				shapeObj = sim.addBox( { x:meters(skin.x), y:meters(skin.y), width:meters(skin.width), height:meters(skin.height), skin:skin } );	
			}
			else if (skinType == "22" || skinType == "24" || skinType == "69") //circles
			{
				shapeObj = sim.addCircle( { x:meters(skin.x), y:meters(skin.y), radius:meters(skin.width / 2), friction:0.8, skin:skin } );	
			}
			else if (skinType == "41") //bouncy circles
			{
				shapeObj = sim.addCircle( { x:meters(skin.x), y:meters(skin.y), radius:meters(skin.width / 2), restitution:0.6, friction:0.8, skin:skin } );	
			}
			else if (skinType == "44") //less bouncy circles
			{
				shapeObj = sim.addCircle( { x:meters(skin.x), y:meters(skin.y), radius:meters(skin.width / 2), restitution:0.3, friction:0.8, skin:skin } );	
			}			
			else if (skinType == "0" || skinType == "60") //hexahedron
			{
				shapeObj = sim.addPoly( { x:meters(skin.x), y:meters(skin.y), points:[-1.22,0,-0.48,-1.12,0.9,-1.11,1.6,0,0.88,1.11,-0.49,1.12,-1.22,0], skin:skin } );
			}
			else if (skinType == "1" || skinType == "61") //pentagon
			{
				shapeObj = sim.addPoly( { x:meters(skin.x), y:meters(skin.y), points:[0.01,-1.01,1.13,-0.13,0.69,1.17,-0.71,1.16,-1.12,-0.18,0.01,-1.01], skin:skin } );				
			}
			else if (skinType == "7" || skinType == "67") //star
			{
				shapeObj = sim.addPoly( { x:meters(skin.x), y:meters(skin.y), points:[0, -1.14,-0.42, -0.48,-1.2, -0.27,-0.67, 0.34,-0.77, 1.14,0, 0.82,0.75, 1.15,	0.69, 0.32,	1.2, -0.26,	0.43, -0.02,0,-1.14], skin:skin } );			
			}
			else if (skinType == "8") //triangle
			{
				shapeObj = sim.addPoly( { x:meters(skin.x), y:meters(skin.y), points:[0,-0.98,1.12,0.98,-1.12,0.99,0,-0.98], skin:skin } );			
			}
			else if (skinType == "12") //freezing triangle
			{
				shapeObj = sim.addPoly( { x:meters(skin.x), y:meters(skin.y), points:[-0.7,-0.96,-0.7,0.94,2,0.94,-0.7,-0.96], skin:skin } );			
			}
			else if (skinType == "13") //heptahedron
			{
				shapeObj = sim.addPoly( { x:meters(skin.x), y:meters(skin.y), points:[0,-0.9,0.79,-0.51,0.99,0.33,0.44,1.06,-0.45,1.06,-0.98,0.35,-0.79,-0.51,0,-0.9], skin:skin } );			
			}
			else if (skinType == "14") //parallelogram
			{
				shapeObj = sim.addPoly( { x:meters(skin.x), y:meters(skin.y), points:[-1.25,0.7,-0.3,-1.03,1.81,-1.04,0.91,0.7,-1.25,0.7], skin:skin } );			
			}
			else if (skinType == "15") //pink triangle
			{
				shapeObj = sim.addPoly( { x:meters(skin.x), y:meters(skin.y), points:[0.9,-0.5,-0.29,1.53,-1.49,-0.51,0.9,-0.5], skin:skin } );			
			}
			else if (skinType == "68") //ny "triangle" - shapka.
			{
				shapeObj = sim.addPoly( { x:meters(skin.x), y:meters(skin.y), points:[-0.2,-0.7,0.29,-0.7,1.12,1.01,-1.03,1.05,-0.2,-0.7], skin:skin } );			
			}
			else if (skinType == "20") //crab
			{				
				shapeObj = sim.addPoly( { x:meters(skin.x), y:meters(skin.y), points:[0,-0.35,0.47,-0.48,0.8,-0.5,1.64,0.27,0.99,1.03,-0.98,1.02,-1.64,0.31,-0.81,-0.47,-0.48,-0.46,0,-0.35], skin:skin  } );			
			}
			else if (skinType == "21") //greenfish
			{				
				shapeObj = sim.addPoly( { x:meters(skin.x), y:meters(skin.y), points:[1,-0.8,0.97,1.13,-0.78,1.12,-1.38,0.15,-0.76,-0.81,1,-0.8], skin:skin } );			
			}
			else if (skinType == "23") //hippocampus
			{				
				shapeObj = sim.addPoly( { x:meters(skin.x), y:meters(skin.y), points:[-0.25,-1.4,1.06,-1.44,1.07,1.73,0.52,1.86,-0.48,1.76,-0.64,1.36,-0.65,0.86,-0.33,0.58,0.2,0.62,0.01,0.22,0.07,-0.01,0.49,-0.82,0.32,-1,-0.56,-0.74,-0.65,-0.9,0.05,-1.25,-0.25,-1.4], skin:skin  } );			
			}
			else if (skinType == "25") //triangleFish
			{				
				shapeObj = sim.addPoly( { x:meters(skin.x), y:meters(skin.y), points:[1,0,-1.04,1.13,-1.07,-1.1,1,0], skin:skin } );			
			}
			else if (skinType == "40") //bag
			{
				shapeObj = sim.addPoly( { x:meters(skin.x), y:meters(skin.y), points:[-1.1,-0.7,-0.88,1.01,1.46,1.01,1.65,-0.66,-1.1,-0.7], skin:skin } );	
			}
			else if (skinType == "45") //tanner cream tubic
			{
				shapeObj = sim.addPoly( { x:meters(skin.x), y:meters(skin.y), points:[-0.57,-1.3,-0.27,0.81,-0.27,1.14,0.46,1.15,0.47,0.82,0.76,-1.3,-0.57,-1.3], skin:skin } );	
			}
			else if (skinType == "70") //rural (for NY)
			{
				shapeObj = sim.addPoly( { x:meters(skin.x), y:meters(skin.y), points:[0.8,-0.87,0.82,0.54,0.64,0.79,-0.86,0.78,-1.02,0.39,-0.87,0.07,-0.17,0.03,-0.11,-0.89,0.8,-0.87], skin:skin  } );	
			}
			else if (skinType == "777") //nano shape
			{
				shapeObj = sim.addPoly( { x:meters(skin.x), y:meters(skin.y), points:[0.14,-0.2,0.45,0.03,-0.03,0.53,-0.51,0.02,-0.21,-0.19,0.14,-0.2], skin:skin } );	
			}		
			else if (skinType == "888") //bar shape
			{
				shapeObj = sim.addPoly( { x:meters(skin.x), y:meters(skin.y), points:[-1.9,-0.3,-1.58,0.1,2.2,0.1,2.55,-0.33,2.57,0.37,-1.93,0.36,-1.9,-0.3], skin:skin, density:0 } );	
			}
			
			return shapeObj;			
		}
		
		public static function addBoundaries(worldMC:World, sim:QuickBox2D, pedestalType:int):void//QuickObject
		{			
			var he:int = Misc.GAME_AREA_HEIGHT;
			var wi:int = Misc.GAME_AREA_WIDTH;
			sim.addBox( { x:meters(-200), y:meters(he) / 2, width:0.2, height:800, density:0, fillAlpha:0, lineAlpha:0, groupIndex:-1 } );		//heigt 800 - because stacking up can go very high) 	
			sim.addBox( { x:meters(wi) / 2, y:meters(he), width:meters(wi), height:0.2, density:0, fillAlpha:0, lineAlpha:0, groupIndex:-1} );
			sim.addBox( { x:meters(1200), y:meters(he) / 2, width:0.2, height:800, density:0, fillAlpha:0, lineAlpha:0, groupIndex:-1 } );  //groupIndex:-1  -> for not colliding between borders
			
			var assetClass:Class;
            var frontShell:MovieClip;
            var frontShell2:MovieClip;
            var pedestal:MovieClip;

			if (pedestalType == 0) //seashell
			{
				sim.addPoly( {
                    x:meters(worldMC.mc.static_mc.shell_mc.x + worldMC.mc.static_mc.shell_mc.width / 2 + 15),
                    y:meters(worldMC.mc.static_mc.shell_mc.y - worldMC.mc.y) + 1.3,
                    points:[-5.77,-1.39,-5.97,-0.94,-5.97,1.86,4.94,1.88,4.94,-0.67,4.88,-1.05,4.73,-1.29,4.68,-0.64,4.39,-0.3,3.76,0.08,2.38,0.46,0.86,0.8,-0.86,0.78,-2.49,0.68,-3.91,0.4,-5.02,-0.1,-5.56,-0.54],
                    draggable:false, density:0, fillAlpha:0, lineAlpha:0 } );
				assetClass = getDefinitionByName("front") as Class;
				frontShell = new assetClass();
				frontShell.x = 252.2 + worldMC.mc.x;
				frontShell.y = 521 + worldMC.mc.y;
				worldMC.parent.addChild(frontShell);
				frontShell2 = new assetClass();
				frontShell2.x = 252.2;
				frontShell2.y = 521;
				frontShell2.name = "frontShell2";
				worldMC.mc.addChild(frontShell2); //this is for screenshot. cause worldMc is being snapshted
			}
			else if (pedestalType == 1)
            {
                assetClass = getDefinitionByName("lounge") as Class;
                pedestal = new assetClass();
                pedestal.cacheAsBitmap = true;
                pedestal.x = wi / 2 + 80; //left-top reg point
                pedestal.y = he - 110;

                sim.addPoly( { x:meters(pedestal.x), y:meters(pedestal.y), points:[3.48, -2.8, 0.32, 0.05, -5.70, 0.02, -5.33, 2.77, 3.45, 2.77, 3.53, -2.8], draggable:false, skin:pedestal, density:0  } );
            } //lounge
			else if (pedestalType == 2) 
			{
                pedestal = worldMC.mc.sledge_mc;
				sim.addPoly( { x:meters(pedestal.x), y:meters(pedestal.y), points:[ -5.4, -1.91, -5.06, -1.19, -4.53, -0.66, -4.06, -0.28, -3.58, -0.01, -3.06, 0.19, -2.38, 0.36, -1.78, 0.36, -0.03, 0.36, 6.2, 0.37, 6.5, 0.19, 6.6, -0.18, 6.72, -0.96, 6.92, -0.99, 6.99, 3.07, -4.63, 3.19, -5.43, -1.93], draggable:false, skin:pedestal, density:0  } );	 //sledge
				
				assetClass = getDefinitionByName("frontSledge") as Class;
				frontShell = new assetClass();
				frontShell.x = worldMC.mc.sledge_mc.front_mc.x + worldMC.mc.sledge_mc.x + worldMC.mc.x;
				frontShell.y = worldMC.mc.sledge_mc.front_mc.y + worldMC.mc.sledge_mc.y + worldMC.mc.y;
				worldMC.parent.addChild(frontShell);
				frontShell2 = new assetClass();
				frontShell2.x = worldMC.mc.sledge_mc.front_mc.x + worldMC.mc.sledge_mc.x;
				frontShell2.y = worldMC.mc.sledge_mc.front_mc.y + worldMC.mc.sledge_mc.y;
				frontShell2.name = "front2";
				worldMC.mc.addChild(frontShell2); //this is for screenshot. cause worldMc is being snapshoted
				worldMC.mc.sledge_mc.removeChild(worldMC.mc.sledge_mc.front_mc);
			}
		}
		
		public static function meters(pixels:Number):Number
		{
			return pixels / 30;
		}	
		
		public static function radians(degs:Number):Number
		{  
			return degs * Math.PI / 180;  
		}  		
	}
}