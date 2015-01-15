using System;
using System.Collections.Generic;
using PlayerIO.GameLibrary;

namespace ServerSide
{
	public class Player : BasePlayer
	{
		private int _myColor = -1;
		public int Points = 0;
		public bool HasInfinity = false;
		public bool Creator;		
		public Dictionary<string, DateTime> PowerupLastUses;
	    public string ID = "";

		public bool IsDummy;
		public int DummyStartPosition;

		public void Create(int colorr, bool creatorr)
		{
			if (ConnectUserId != null) 
                ID = ConnectUserId; //for non-dummies players
			_myColor = colorr;
			Points = 0;
			Creator = creatorr;			
			PowerupLastUses = new Dictionary<string, DateTime>();
		}

		public void CheckForInfinity() //this function is called on every game start. hasInfinity is then used at powerupCheck when using powerup
		{
			Console.WriteLine("checkForInfinity");
			string[] infinityTypes = { "1", "3", "7", "30" };
			PayVault.Refresh(delegate
			{
				foreach (var t in infinityTypes)
				{
				    if (!PayVault.Has("infinity" + t)) continue;
				    HasInfinity = true;
				    var infinity = PayVault.First("infinity" + t);
				    var secondsUNIX = infinity.GetUInt("expires");
				    var secondsNow = (uint)Math.Round((DateTime.UtcNow - new DateTime(1970, 1, 1, 0, 0, 0)).TotalSeconds);
				    Console.WriteLine("secondsUNIX: " + secondsUNIX);
				    Console.WriteLine("secondsNow: " + secondsNow);
				    if (secondsNow > secondsUNIX) //infinity expired
				    {
				        HasInfinity = false;
				        PayVault.Consume(new[] { infinity }, delegate { });
				    }
				    break;
				}					
			});			
		}

		public int Color
		{
			get
			{
				return _myColor;
			}
			set
			{
				_myColor = value;
			}
		}
	}
}
