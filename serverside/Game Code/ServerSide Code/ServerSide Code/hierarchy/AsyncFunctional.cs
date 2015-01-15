using System;
using System.Collections;
using System.Globalization;
using PlayerIO.GameLibrary;

namespace ServerSide
{
    public abstract class AsyncFunctional : AsyncWordSeekers
    {
        protected ArrayList Admins = new ArrayList {"73920149", "2333010", "1308033905", "14566632080"};

        protected void ProcessAddToGuysAsync(bool adminAsUser)
        {
            if (Admins.IndexOf(Creator.ConnectUserId) != -1 && !adminAsUser)
            {
                switch (RoomData["game"])
                {
                    case "snake":
                        StartSnakeAdminGame(); //uses counter to select preferred scenario
                        break;
                    case "wordSeekers":
                        StartWordSeekersAdminGame();
                        break;
                }
            }
            else
            {
                switch (RoomData["game"])
                {
                    case "snake":
                        LoadSnakeGamesCounter();
                        break;
                    case "wordSeekers":
                        LoadWordSeekersGamesCounter();
                        break;
                }
            }
        }

        protected override void OnScenarioCountLoaded(DatabaseObject scenarioCount)
            //allows to manually use unused (preferred scanarios), so all 100 will be saved as used in SnakeGames
        {
            Console.WriteLine("onScenarioCountLoaded");
            ScenarioNumber = scenarioCount.GetInt("value");
            scenarioCount.Set("value", scenarioCount.GetInt("value") + 1);
            scenarioCount.Save();
            GameID = 0;
            DummyTurns = new DatabaseArray();

            //Not caring about relistic data. Admin plays game for creating (using) yet unused scenario. Let the oppponent's snake move only forward
            var fakePlayer = new Player {IsDummy = true, ID = (Rand.Next(10000)).ToString(CultureInfo.InvariantCulture)};
            Guys[fakePlayer.ID] = fakePlayer;
            Guys[fakePlayer.ID].Create((int) PlayersColors[Guys.Count - 1], false);
            Guys[fakePlayer.ID].DummyStartPosition = 1;
            SendUsersInfo(Creator.PlayerObject); //moreover admin will play "against" himself
            ScenarioReloadCounter = 0;
        }

        protected override void SendUsersInfo(DatabaseObject opponentObj)
        {
            var players = "";
            var colors = "";
            var levels = "";
            var counter = 0;

            foreach (var guy in Guys.Values)
            {
                Console.WriteLine("guy: " + guy.ID);
                counter++;
                var end = (counter == Guys.Values.Count ? "" : ",");

                if (guy.IsDummy) levels += GetCurrentLevel(opponentObj.GetArray("story")) + end;
                else levels += GetCurrentLevel(guy.PlayerObject.GetArray("story")) + end;
                players += guy.ID + end;
                colors += guy.Color + end;
            }
            Creator.Send("data", players, colors, levels, WhatToSend());
        }

        private int WhatToSend()
        {
            var toSend = 0;
            switch (RoomData["game"])
            {
                case "snake":
                    toSend = GameID;
                    break;
                case "wordSeekers":
                    toSend = ScenarioNumber;
                    break;
            }
            return toSend;
        }

        protected void SoloFinish(string players, string scores, string winnerID = null, string loserID = null)
        {
            Console.WriteLine("soloFinish");
            if (winnerID == Creator.ID) //user (creator) won
            {
                var currentStreak = CopyArray(Creator.PlayerObject.GetArray("streak"));
                if (DudeAintInStreak(currentStreak, loserID))
                    currentStreak.Set(currentStreak.Count, loserID);
                        //adding to losers only those players who r not at your streak  ( and not adding yourself:) )				
                Console.WriteLine("currentStreak.Count: " + (currentStreak.Count));

                UpdateStoriesAndSpiral(winnerID, loserID, currentStreak.Count - 1 == 0);

                if (currentStreak.Count > 7)
                    //If "before" + "added now" > streak length needed 2 win -> Streak completed. Give prize
                {
                    Console.WriteLine("WON JACKPOT");
                    PlayerIO.BigDB.Load("Jackpot", "jp", delegate(DatabaseObject dbObj)
                    {
                        var cashAmount = dbObj.GetUInt("value"); //amount of powerups
                        dbObj.Set("value", (uint) 0);
                        dbObj.Set("count", dbObj.GetUInt("count") + 1);
                        dbObj.Save();

                        Creator.PayVault.Credit(cashAmount, "won jackpot", null, HandleError);

                        var winnerObj = new DatabaseObject();
                        winnerObj.Set("id", winnerID);
                        winnerObj.Set("prize", cashAmount);
                        winnerObj.Set("date", DateTime.UtcNow);
                        PlayerIO.BigDB.CreateObject("Jackpot",
                            (dbObj.GetUInt("count")).ToString(CultureInfo.InvariantCulture), winnerObj, delegate { },
                            HandleError);

                        Creator.Send("finishjp", players, scores, cashAmount);
                        ClearStreak(Creator);
                    });
                }
                else //regular victory
                {
                    Creator.PlayerObject.Set("streak", CopyArray(currentStreak));
                    Creator.PlayerObject.Save();
                    Creator.Send("finish", players, scores);
                }
            }
            else //No winner. No changes.
            {
                StorySaved = true;
                SpiralSaved = true;
                Creator.Send("finish", players, scores);
            }
        }

        protected bool DudeAintInStreak(DatabaseArray currentStreak, string dudeID)
        {
            var result = true;
            foreach (string uid in currentStreak)
            {
                if (uid == dudeID)
                {
                    result = false;
                }
            }
            return result;
        }

        protected DatabaseArray CopyArray(DatabaseArray toCopy, string type = "string")
        {
            var newArr = new DatabaseArray();
            foreach (var t in toCopy)
            {
                if (type == "string" && t != null)
                    newArr.Add(Convert.ToString(t));
                else if (type == "DatabaseObject" && t != null)
                    newArr.Add((DatabaseObject) t);
            }
            return newArr;
        }
    }
}