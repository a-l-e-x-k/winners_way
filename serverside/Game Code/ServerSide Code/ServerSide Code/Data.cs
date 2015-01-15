using System.Collections;
using System.Collections.Generic;

namespace ServerSide
{
	class Data
	{
		public const int CAPACITY = 2;

		public static string[] Letters
		{
			get
			{
				//string[] _letters = { "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z" };
				string[] letters = { "а", "б", "в", "г", "д", "е", "ё", "ж", "з", "и", "й", "к", "л", "и", "н", "о", "п", "р", "с", "т", "у", "ф", "х", "ц", "ч", "ш", "щ", "ъ", "ы", "ь", "э", "ю", "я"};
				return letters;
			}
		}

		public static string[] Fruits
		{
			get
			{
				//string[] _fruits = { "apple", "peach", "lime", "lemon", "mandarin", "orange", "pomelo", "fig", "avocado", "guava", "lychee", "peanut", "melon", "olive", "badger", "bat", "deer", "fox", "hare", "mole", "mouse", "otter", "rabbit", "chokeberry", "squirrel", "stoat", "weasel", "crow", "dove", "duck", "goose", "hawk", "heron", "peafowl", "pigeon", "robin", "rook", "swan", "ant", "bee", "moth", "fly", "spider", "pike", "salmon", "frog", "snake", "crab", "lobster", "clam", "snail", "circle", "oval", "cone", "cube", "bull", "cow", "sheep", "piglet", "hen", "egg", "beef", "bread", "corn", "butter", "pork", "rice", "salt", "sugar"  };
				string[] fruits = { "яблоко", "персик", "лайм", "лимон", "мандарин", "апельсин", "помело", "фиг", "авокадо", "гуава", "личи", "арахис", "дыня", "олива", "барсук", "мышь", "олень", "лиса", "заяц", "моль", "крыса", "выдра", "кролик", "арония", "белка", "горностай", "ласка", "ворона", "голубь", "утка", "гусь", "ястреб", "цапля", "павлин", "дрозд", "грач", "лебедь", "муравей", "пчела", "бабочка", "муха", "паук", "щука", "лосось", "лягушка", "змея", "краб", "лобстер", "моллюск", "улитка", "круг", "овал", "конус", "куб", "бык", "корова", "овца", "курица", "яйцо", "хлеб", "масло", "свинина", "рис", "соль", "сахар" };
				return fruits;
			}
		}

		public static string[] PowerupNames
		{
			get
			{
				string[] names = { "boost2x", "boost3x", "missile", "sevenMines", "grid", "firstLetter", "removeLetters", "swapShape", "nanoShape", "undo", "flyingbar" };
				return names;
			}
		}

		public static string[] GetGamePowerups (int gameIndex)
		{
			string[] result = null;
			switch (gameIndex)
			{
			    case 0:
			        result = new[] { "boost2x", "boost3x", "missile", "sevenMines", "grid" };
			        break;
			    case 1:
			        result = new[] {"swapShape", "nanoShape", "undo", "flyingbar" };
			        break;
			    case 2:
			        result = new[] { "firstLetter", "removeLetters" };
			        break;
			}
			return result;
		}

		public static Dictionary<string, int> PowerupDelay // includes powerup lifetime
		{
			get
			{
				var values = new Dictionary<string, int>();
				values["bo2"] = 11000; //boost 2x
				values["bo3"] = 15000; //boost 3x
				values["mi"] = 15000; //mine
				values["sm"] = 5000; //seven mines
				values["gr"] = 0; //grid
				values["rl"] = 10000; //remove letters
				values["fl"] = 20000; //first letter				
				values["sw"] = 30000; //swap shape
				values["ns"] = 30000; //nano shape
				values["un"] = 21000; //undo (remove last shape)
				values["fb"] = 60000; //flying bar (remove last shape)
				return values;
			}
		}

		public static Dictionary<string, string> PowerupNameByMessageType 
		{
			get
			{
				var values = new Dictionary<string, string>();
				values["bo2"] = "boost2x"; 
				values["bo3"] = "boost3x";
				values["mi"] = "missile";
				values["sm"] = "sevenMines"; 
				values["gr"] = "grid";
				values["rl"] = "removeLetters";
				values["fl"] = "firstLetter";				
				values["sw"] = "swapShape"; 
				values["ns"] = "nanoShape"; 
				values["un"] = "undo";
				values["fb"] = "flyingbar";
				return values;
			}
		}

		public static Dictionary<string, int> PowerupPrices
		{
			get
			{
				var values = new Dictionary<string, int>();
				values["boost2x"] = 11; 
				values["boost3x"] = 16; 				
				values["sevenMines"] = 11;
				values["missile"] = 20;
				values["grid"] = 15;
				values["removeLetters"] = 15;
				values["firstLetter"] = 17;
				values["swapShape"] = 10;
				values["nanoShape"] = 18;
				values["undo"] = 19;
				values["flyingbar"] = 20;
				return values;
			}
		}

		public static uint[] GetPackData(int packIndex) //returns amount, price
		{
				uint[] result = {}; 
				if (packIndex == 0) result = new uint[] { 5, 700 };
				else if (packIndex == 1) result = new uint[] { 10, 1300 };
				else if (packIndex == 2) result = new uint[] { 20, 2200 };								
				return result;			
		}

		public static uint[] GetInfinityData(int infinityIndex) //returns time, price
		{
			uint[] result = { };			
			switch (infinityIndex)
			{
			    case 0:
			        result = new uint[] { 1, 950 }; //approx. 60 powerups
			        break;
			    case 1:
			        result = new uint[] { 3, 1600 };
			        break;
			    case 2:
			        result = new uint[] { 7, 3000 };
			        break;
			    case 3:
			        result = new uint[] { 30, 9000 };
			        break;
			}			
			return result;
		}

		public static Dictionary<int, int> LevelLength // includes powerup lifetime
		{
			get
			{
				var values = new Dictionary<int, int>();
				values[1] = 5;
				values[2] = 6;
				values[3] = 8;
				values[4] = 8;
				values[5] = 10;
				values[6] = 9;
				values[7] = 9;
				values[8] = 8;
				values[9] = 10;
				values[10] = 7;
				return values;
			}
		}

		public static ArrayList LevelStreakStartIndexes(int levelIndex) // includes powerup lifetime
		{
			var streakStarts = new ArrayList();
			switch (levelIndex)
			{
			    case 1:
			        streakStarts.Add(0);
			        streakStarts.Add(1);
			        streakStarts.Add(2);
			        streakStarts.Add(3);
			        streakStarts.Add(4);
			        break;
			    case 2:
			        streakStarts.Add(0);
			        streakStarts.Add(1);
			        streakStarts.Add(2);
			        streakStarts.Add(4);
			        streakStarts.Add(5);
			        break;
			    case 3:
			        streakStarts.Add(0);
			        streakStarts.Add(1);
			        streakStarts.Add(3);
			        streakStarts.Add(4);
			        streakStarts.Add(7);
			        break;
			    case 4:
			        streakStarts.Add(0);
			        streakStarts.Add(2);
			        streakStarts.Add(4);
			        streakStarts.Add(5);
			        break;
			    case 5:
			        streakStarts.Add(0);
			        streakStarts.Add(2);
			        streakStarts.Add(5);
			        streakStarts.Add(6);
			        streakStarts.Add(9);
			        break;
			    case 6:
			        streakStarts.Add(0);
			        streakStarts.Add(3);
			        streakStarts.Add(4);
			        streakStarts.Add(8);
			        break;
			    case 7:
			        streakStarts.Add(0);
			        streakStarts.Add(3);
			        streakStarts.Add(4);
			        break;
			    case 8:
			        streakStarts.Add(0);
			        streakStarts.Add(2);
			        break;
			    case 9:
			        streakStarts.Add(0);
			        streakStarts.Add(4);
			        break;
			    case 10:
			        streakStarts.Add(0);
			        break;
			}
			return streakStarts;
		}	
	}
}
