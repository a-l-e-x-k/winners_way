using System;
using System.Collections.Generic;
using System.Globalization;
using PlayerIO.GameLibrary;

namespace ServerSide
{
	/*
	 * Saves statistic data in Statistics table in BigDB.
	 */
	public abstract class StatisticsManager : VKPaymentProcessor
	{
		protected void SaveVKViralData(string uid, string dataType)
		{
			PlayerIO.BigDB.Load("Statistics", "virality", delegate(DatabaseObject obj)
			{
			    switch (dataType)
			    {
			        case "inv":
			        {
			            obj.Set("friendsInvited", obj.GetInt("friendsInvited") + 1); //frind was invited
			            var inviters = obj.GetObject("inviters").GetArray("a");
			            inviters.Add(uid);
			        }
			            break;
			        case "ph":
			        {
			            obj.Set("photosSaved", obj.GetInt("photosSaved") + 1); //photo was saved to album
			            var savers = obj.GetObject("savers").GetArray("a");
			            savers.Add(uid);
			        }
			            break;
			        case "wp":
			        {
			            obj.Set("wallPosts", obj.GetInt("wallPosts") + 1); //photo was saved to album
			            var posters = obj.GetObject("posters").GetArray("a");
			            posters.Add(uid);
			        }
			            break;
			    }
			    obj.Save();
			});
		}

		protected void SaveVKReferrerData(string uid, string dataType)
		{
			PlayerIO.BigDB.Load("Statistics", "referrers", delegate(DatabaseObject obj)
			{
				if (dataType == "menu") obj.Set("leftMenu", obj.GetInt("leftMenu") + 1); //frind was invited
				else if (dataType == "wp") obj.Set("fromInvite", obj.GetInt("fromInvite") + 1); //frind was invited
				else if (dataType == "l") obj.Set("other", obj.GetInt("other") + 1); //frind was invited
				else if (dataType == "cat") obj.Set("catalog", obj.GetInt("catalog") + 1); //frind was invited
				else if (dataType == "myapps") obj.Set("myapps", obj.GetInt("myapps") + 1); //frind was invited
				obj.Save();
			});
		}

		protected void UpdatePowerupStatistics(Dictionary<string, uint> powerupUses)
		{
			var gameObject = new DatabaseObject();
			foreach (var powerupType in powerupUses.Keys) //writing down statistics for each powerup-type use 
			{
				gameObject.Set(powerupType, powerupUses[powerupType]);
			}
			PlayerIO.BigDB.CreateObject("PowerupStatistics", (DateTime.UtcNow - (new DateTime(1970, 1, 1))).TotalMilliseconds.ToString(CultureInfo.InvariantCulture), gameObject, null);

		}

		protected void UpdateGamesCounter()
		{
			PlayerIO.BigDB.Load("Statistics", "gamesPlayed", delegate(DatabaseObject gameCounter) //that thing just for info. Each room has random id.
			{
				gameCounter.Set("total", gameCounter.GetInt("total") + 1); //update number of games played 
				
				switch (RoomData["game"])
				{
					case "snake":
						gameCounter.Set("snake", gameCounter.GetInt("snake") + 1);
						break;
					case "stackUp":
						gameCounter.Set("stackUp", gameCounter.GetInt("stackUp") + 1);
						break;
					case "wordSeekers":
						gameCounter.Set("wordSeekers", gameCounter.GetInt("wordSeekers") + 1);
						break;					
				}

				gameCounter.Save();
			});
		}

		protected void SavePopupStatistics(string result)
		{
			PlayerIO.BigDB.Load("Statistics", "invitePopup", delegate(DatabaseObject invitePopup) //that thing just for info. Each room has random id.
			{
				if (result == "ok") invitePopup.Set("accepted", invitePopup.GetInt("accepted") + 1);
				else invitePopup.Set("denied", invitePopup.GetInt("denied") + 1);
				invitePopup.Save();
			});
		}
	}
}
