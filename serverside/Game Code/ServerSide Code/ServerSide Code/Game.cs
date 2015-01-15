using System;
using System.Collections;
using System.Collections.Generic;
using PlayerIO.GameLibrary;

namespace ServerSide
{
	public abstract class Game
	{
		public Random Rand = new Random();
		protected Dictionary<string, Player> Guys;
		protected GameManager RoomClass;

		protected ArrayList Newbies(string propertyName)
		{
			var newbies = new ArrayList();
			foreach (var player in Guys.Values)
			{
				if (player.PlayerObject.Contains(propertyName)) 
                    newbies.Add(player.ConnectUserId);
			}
			return newbies;
		}

		protected void FinishGame(string loser = "")
		{
			var maxScore = -1;
			var count = 0;
			var maxScoreCount = 0; //used 2 determine whether winner exists

			var scores = "";
			var players = "";
			var winnerId = "";
			var loserId = "";

			if (loser != "") //turn-based 2-player game
			{
			    foreach (var pl in Guys.Values)
			    {
			        Guys[pl.ConnectUserId].Points = pl.ConnectUserId == loser ? 0 : 1;
			    } //give winner a point. (for further function to work)
			}

			foreach (var uid in Guys.Keys)
			{
				if (maxScore < Guys[uid].Points)
				{
					maxScore = Guys[uid].Points;
					winnerId = uid;
				}

				count++;
				players += uid + (count == Guys.Count ? "" : ",");
				scores += Guys[uid].Points + (count == Guys.Count ? "" : ",");
			}

			foreach (var player in Guys.Values)
			{
				if (player.Points == maxScore) 
                    maxScoreCount++;
			}

			if (maxScoreCount == 1) //we have a winner (there exists only 1 guy with maxScore)
			{
				foreach (var uid in Guys.Keys)
				{
					if (uid != winnerId) loserId = uid;
				}
			}
			else
			{
				winnerId = null;
				loserId = null;
			}

			RoomClass.FinishGame(players, scores, winnerId, loserId);
		}

		public abstract void HandleSpecialMessage(Player player, Message message);
		public abstract void UsePowerup(Player sender, Message message);
	}
}
