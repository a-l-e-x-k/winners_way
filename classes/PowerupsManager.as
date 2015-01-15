package  
{
	import playerio.PayVault;
	import playerio.VaultItem;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class PowerupsManager 
	{
		public static const POWERUPS:Array = ["boost2x", "boost3x", "sevenMines", "grid", "missile", "firstLetter", "removeLetters", "swapShape", "nanoShape", "undo", "flyingbar"];
		public static const DURATIONS:Array = [1, 3, 7, 30]; //amount of days
		public static var infinityExpires:Number = -1; //UNIX-time in seconds when infinity will end
		
		public static var DEFAULT_POWERUPS:Array = [
				{type:"boost2x", amount:3},
				{type:"boost3x", amount:3},
				{type:"sevenMines", amount:3},
				{type:"grid", amount:3 },	
				{type:"missile", amount:3},
				{type:"swapShape", amount:3},
				{type:"nanoShape", amount:3},
				{type:"undo", amount:3},
				{type:"flyingbar", amount:3},
				{type:"freezeShapes", amount:3},				
				{type:"firstLetter", amount:3},
				{type:"removeLetters", amount:3}
		];
		
		public static var powerups:Array = []; //array of available powerups objects		
		
		public static function setDefaults():void
		{
			powerups = DEFAULT_POWERUPS;
		}
		
		public static function checkForInfinity(vault:PayVault):void
		{
			var vaultItem:VaultItem;
			for (var i:int = 0; i < DURATIONS.length; i++) 
			{
				vaultItem = vault.first("infinity" + DURATIONS[i].toString());
				if (vaultItem != null)
				{
					trace("user has infinity");
					var boughtAtUNIXSeconds:Number = Math.round(vaultItem.purchaseDate.time / 1000);
					trace("boughtAtUNIXSeconds: " + boughtAtUNIXSeconds);
					var expiresAt:Number = boughtAtUNIXSeconds + DURATIONS[i] * 24 * 60 * 60;
					trace("expiresAt: " + expiresAt);
					infinityExpires = expiresAt;
				}
			}
		}
		
		public static function savePowerups():void
		{
			for (var i:int = 0; i < POWERUPS.length; i++) 
			{
				powerups.push( { type:POWERUPS[i], amount:Networking.client.payVault.count(POWERUPS[i]) } ); 
			}
		}
		
		public static function addPowerup(powerupType:String, amount:int):void
		{
			for (var j:int = 0; j < powerups.length; j++) 
			{
				if (powerupType == powerups[j].type)
				{
					powerups[j].amount += amount;
					trace("added: " + amount + "  to: " + powerupType);
				}
			}			
		}
		
		public static function getPowerupAmount(powerupType:String):int
		{
			var amount:int = 0;
			for (var j:int = 0; j < powerups.length; j++) 
			{
				if (powerupType == powerups[j].type)
				{
					amount = powerups[j].amount;
				}
			}			
			return amount;
		}
		
		public static function usePowerup(powerupName:String):void
		{
			if (infinityExpires == -1) //don;t use powerup when infinity is turned on
			{
				for (var j:int = 0; j < powerups.length; j++) 
				{
					if (powerupName == powerups[j].type)
					{
						powerups[j].amount -= 1;
						trace("used: " + powerupName);
					}
				}
			}
		}	
		
		public static function meZero(powerupName:String):Boolean
		{
			var zeroLeft:Boolean = false;
			for (var j:int = 0; j < powerups.length; j++) 
			{
				if (powerupName == powerups[j].type)
				{
					if (powerups[j].amount < 1) zeroLeft = true;
				}
			}
			return zeroLeft;
		}
		
		public static function addPack(packID:int):void
		{
			var packInfo:Object = getPackInfo(packID);			
			for (var k:int = 0; k < powerups.length; k++) 
			{
				powerups[k].amount += packInfo.ofEach; //add powerups for target game
			}
		}
		
		public static function goInfinite(infinityID:String):void
		{
			trace("entering infinity mode");
			//set UNIX-time for when infinity will end. Server does it itself, here is just stuff for client
			var ticketData:Object = getTicketInfo(int(infinityID));
			trace("infinty for: " + ticketData.duration);
			var infinitySeconds:Number;
			if (ticketData.duration == 1) infinitySeconds = 24 * 60 * 60;
			else if (ticketData.duration == 3) infinitySeconds = 3 * 24 * 60 * 60;
			else if (ticketData.duration == 7) infinitySeconds = 7 * 24 * 60 * 60;
			else if (ticketData.duration == 30) infinitySeconds = 30 * 24 * 60 * 60;
			
			var currentSeconds:Number = Math.round(new Date().time / 1000);
			trace("currentSeconds: " + currentSeconds);
			var targetDate:Number = currentSeconds + infinitySeconds;
			trace("targetDate: " + targetDate);
			infinityExpires = targetDate;
		}
		
		public static function getPowerupTime(powerupType:String):int // includes powerup lifetime (see function below)
		{
			var time:int = 0;
			if (powerupType == "boost2x") time = 11000;
			else if (powerupType == "boost3x") time = 15000;		
			else if (powerupType == "sevenMines") time = 5000;				
			else if (powerupType == "grid") time = 0;
			else if (powerupType == "missile") time = 15000;
			else if (powerupType == "removeLetters") time = 10000;
			else if (powerupType == "firstLetter") time = 20000;			
			else if (powerupType == "swapShape") time = 30000;
			else if (powerupType == "nanoShape") time = 30000;
			else if (powerupType == "undo") time = 21000;
			else if (powerupType == "flyingbar") time = 60000;			
			return time;
		}
		
		public static function getPowerupShowUseMeTime(powerupType:String):int // time in seconds, when useMe thingy will be showed if powerup was not used
		{
			var time:int = 0;
			if (powerupType == "boost2x") time = 40000;
			else if (powerupType == "boost3x") time = 25000;			
			else if (powerupType == "sevenMines") time = 50000;
			else if (powerupType == "grid") time = 99999999;
			else if (powerupType == "missile") time = 30000;
			else if (powerupType == "removeLetters") time = 20000;
			else if (powerupType == "firstLetter") time = 10000;
			else if (powerupType == "swapShape") time = 40000;
			else if (powerupType == "nanoShape") time = 150000;
			else if (powerupType == "undo") time = 60000;
			else if (powerupType == "flyingbar") time = 100000;			
			return time;
		}
		
		public static function getPowerupLifetime(powerupType:String):int
		{
			var life:int = 0;
			if (powerupType == "boost2x") life = 7000;
			else if (powerupType == "boost3x") life = 7000;		
			return life;
		}
		
		public static function getPowerupsForGame(gameName:String):Array
		{
			var array:Array = [];
			if (gameName == Misc.WORD_SEEKERS_GAME) array = ["firstLetter", "removeLetters"];
			if (gameName == Misc.SNAKE_GAME) array = ["boost2x", "boost3x", "sevenMines", "missile", "grid"];
			if (gameName == Misc.STACK_UP_GAME) array = ["swapShape", "nanoShape", "undo", "flyingbar"];
			return array;
		}		
		
		public static function getPrice(powerupName:String):int //returns price in coins. AVG price is ~31.2 coins
		{
			var price:int = 0;
			if (powerupName == "boost2x") price = 22;
			else if (powerupName == "boost3x") price = 32;
			else if (powerupName == "sevenMines") price = 20;			
			else if (powerupName == "missile") price = 40;
			else if (powerupName == "grid") price = 30;
			else if (powerupName == "removeLetters") price = 30;
			else if (powerupName == "firstLetter") price = 35;
			else if (powerupName == "swapShape") price = 20;
			else if (powerupName == "nanoShape") price = 35;
			else if (powerupName == "undo") price = 40;
			else if (powerupName == "flyingbar") price = 40;
			return price;
		}
		
		public static function getPackInfo(index:int):Object //returns price in coins & amount
		{
			var result:Object; //total powerups price: 172
			if (index == 0) result = { ofEach:5, price:1500 };
			else if (index == 1) result = { ofEach:10, price:2600 };
			else if (index == 2) result = { ofEach:20, price:4500 };	
			else if (index == 3) result = { ofEach:3, price:0 };	
			return result;
		}
		
		public static function getTicketInfo(index:int):Object 
		{
			trace("index: " + index);
			var result:Object = {};
			if (index == 0) result.price = 2000;
			else if (index == 1) result.price = 3500;
			else if (index == 2) result.price = 6000;
			else if (index == 3) result.price = 17000;
			result.duration = DURATIONS[index];
			return result;
		}
	}
}