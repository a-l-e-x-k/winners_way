using System;
using System.Collections;
using System.Collections.Generic;
using PlayerIO.GameLibrary;

namespace ServerSide.stackUp
{
	public class StackUp : Game
	{
		private const int BasicShapesCount = 16; 
		private const int SeaShapesCount = 6; 
		private const int BeachShapesCount = 6;
		private const int NyShapesCount = 11;
		private const int ThemeTypes = 3; //sea, beach, new year
		private string _whoseTurn = "";
		private int _stabilizedCounter; //when 2 people play & shape dropped -> when it's stabilized at 1st guy, counter++, and 2nd -//-. So it's in sync always
		private Timer _turnTimer;
		private readonly ArrayList _idsOnline = new ArrayList(); //for doing turns. (can't say "next element" in coollection (guys))
		private int _failCounter;
		private int _locationID; //[sea, beach, new year] 

		public StackUp(Dictionary<string, Player> guys, GameManager roomClass)
		{
			Guys = guys;
			RoomClass = roomClass;
			StartGame();
		}

		private void StartGame()
		{
			foreach (var guy in Guys.Values) { _idsOnline.Add(guy.ConnectUserId); }
			_locationID = Newbies("oSU").Count > 0 ? 1 : Rand.Next(ThemeTypes); //if there is a newbie beach location is created (drag matress)
			_whoseTurn = Newbies("oSU").Count > 0 ? (string)(Newbies("oSU")[0]) : (string)_idsOnline[Rand.Next(Data.CAPACITY)];

			RoomClass.ScheduleCallback(delegate
			{
			    foreach (var pla in Guys.Values)
			    {
			        Console.WriteLine(pla.ConnectUserId);
			    }
			    var randomShape = GetRandomShape();
				RoomClass.Broadcast("st", randomShape, _whoseTurn, _locationID);
			}, 1000); //send everybody info. Delay 1 sec so VK will be able to send user's names & use them to display "Turn of [username]"

			AddTurnTimer();
			Console.WriteLine("GAME STARTED");
		}

		public override void HandleSpecialMessage(Player player, Message message)
		{
		    switch (message.Type)
		    {
		        case "0":
		            MoveShape(player.ConnectUserId, message.GetInt(0), message.GetInt(1));//move shape
		            break;
		        case "ds":
		            DropShape(player.ConnectUserId, message.GetString(0));//drop shape
		            break;
		        case "ok":
		            CheckForNextTurn();//no fall
		            break;
		        case "fe":
		            _failCounter++;
		            if (_failCounter == 2) //1 "fail message is not enough"
		            {					
		                _turnTimer.Stop();
		                FinishGame(_whoseTurn);//fell. Other guy wins
		            }
		            break;
		    }
		}

	    private void DropShape(string uid, string data)
		{
	        foreach (var player in Guys.Values)
	        {
	            if (player.ConnectUserId != uid) 
                    player.Send("ds", data); 
	        }			
		}

		private void MoveShape(string uid, int x, int y)
		{
		    foreach (var player in Guys.Values)
		    {
		        if (player.ConnectUserId != uid) 
                    player.Send("0", x, y); 
		    }
		}

		private void CheckForNextTurn()
		{
			_stabilizedCounter++;
		    if (_stabilizedCounter != Data.CAPACITY) return;
		    if (Newbies("oSU").Count > 0) RoomClass.RemoveTutorialProperty("oSU", Guys[_whoseTurn]); //whoseTurn may be only newbie in this case.
		    _whoseTurn = (string)_idsOnline[_idsOnline.IndexOf(_whoseTurn) == 0 ? 1 : 0]; //select other guy
		    var newShapeType = GetRandomShape();
		    RoomClass.Broadcast("nt", _whoseTurn, newShapeType); // next turn				
		    AddTurnTimer();
		}

		public override void UsePowerup(Player sender, Message message)
		{
		    switch (message.Type)
		    {
		        case "sw":
		        {
		            int newShape;
		            do newShape = GetRandomShape(true);	
		            while (newShape == message.GetInt(0)); //get new shape (checking, so u'll not receive the same shape as current)
		            RoomClass.Broadcast("sw", newShape);
		        }
		            break;
		        case "ns":
		            RoomClass.Broadcast("ns"); //nano shape
		            break;
		        case "un":
		            RoomClass.Broadcast("un"); //undo
		            break;
		        case "fb":
		            RoomClass.Broadcast("fb"); //flying bar
		            break;
		    }
		}

	    private int GetRandomShape(bool powerup = false)
		{		
			var randomShape = 0;  //+20 - So ID will be 20 + something. ids 0-20 -for basic, 20-40 r 4 sea theme, 40 - 60 - for beach
			var basic = Rand.Next(100) < 65 && _locationID != 2; //only NY-theme shapes at ny. 80% of shapes are basic
			if (basic) randomShape = Rand.Next(BasicShapesCount);  //basic
			else switch (_locationID)
			{
			    case 0:
			        randomShape = Rand.Next(SeaShapesCount) + 20;  //sea
			        break;
			    case 1:
			        randomShape = Rand.Next(BeachShapesCount) + 40; //beach
			        break;
			    case 2:
			        randomShape = Rand.Next(NyShapesCount) + 60; //ny
			        break;
			}
			if (!powerup) 
                randomShape = Newbies("oSU").Count > 0 ? 42 : randomShape; //if 2 newbies play together then both should start with matress shape			
			return randomShape;
		}

		private void AddTurnTimer()
		{
			_failCounter = 0;
			_stabilizedCounter = 0;
			if (_turnTimer != null) _turnTimer.Stop();
			_turnTimer = RoomClass.AddTimer(delegate
			{
				if (_stabilizedCounter == 0)
				{
					_turnTimer.Stop();
					FinishGame(_whoseTurn); //if noone said that shape stabilized
				}
				else //1 guy said that stabilized, another one that it didn't -> Error
				{
					_turnTimer.Stop();
					RoomClass.Broadcast("er");
				    foreach (var pla in Guys.Values)
				    {
				        RoomClass.TryDisconnect(pla); 
				    }
					RoomClass.CleanUp();
				}
			}, 20000);
		}
	}
}