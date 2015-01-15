package languages 
{
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public class English implements ILanguage
	{
		public const LANGUAGE:String = "ENG";
		
		public function play():String { return("Play"); };
		public function jackpot():String { return("Jackpot");}
		public function mypowerups():String { return("My Powerups"); }
		public function infinityExpires():String { return("Infinity ticket expires in:\n"); };
		public function win():String { return("win");}
		public function more():String { return("more");}
		public function time():String { return("time");}
		public function time2():String { return("time");}
		public function toUnlock():String { return("to unlock"); }
		public function d():String { return("d"); };
		public function h():String { return("h");}
		public function m():String { return("m");}
		public function coins():String { return("coins");}
		public function ago():String { return("ago");}
		public function beforeFinish():String { return("Game will end in:");}
		public function beforeFinishStackup():String { return("Seconds left:");}
        public function intro():String { return('        Just click "Play"... :)');}
        public function flower():String { return('flower');}

        public function connecting():String { return("Connecting...");}
		public function loading():String { return("Loading...");}
		public function findingopponent():String { return("Finding opponent..."); }
		public function awaitingFriend():String { return("Awaiting friend..."); };
		public function connectingToFriend():String { return("Going to friend..."); };
		
		public function notenough():String { return("Ooops.\nNot enough coins.");}
		public function cancel():String { return("Cancel");}
		public function addCoins():String { return("Add coins!");}
		public function success():String { return("Successfully bought!");}
		public function add():String { return("Shop");}
		
		public function toWinjp():String { return("To win jackpot you need to beat 8 different players in a row.");}
		public function descriptionJp():String { return("Every time someone plays a game we add a little bit of coins to the total prize. Amount we add depends on how many powerups were used in the game. So the more powerups you use the bigger and tastier the total pie will be.");}
		
		public function st1():String { return("Stack things on top of each other");}
		public function st2():String { return("If smth falls on ground at your turn - you lose");}
		public function st3():String { return('Turn will switch only if shapes <font color = "#CC0000">are not</font> reeling');}
		public function st4():String { return("Use powerups to save your... turn");}
		
		public function sn1():String { return("Eat fruits");}
		public function sn2():String { return('<font color = "#CC0000">' + "Don't </font> eat yourself");}
		public function sn3():String { return("Biggest wins");}
		
		public function reeling():String { return("Shapes are reeling.\nThat is bad.");}
		public function asyncError():String { return("Oops. Error occured. It will not affect you story and streaks.");}
		public function yourTurn():String { return("Your turn!");}
		public function turnOf():String { return("Turn of");}	
		
		public function ty():String { return("Thank you!");}
		public function giveaway():String { return("Daily giveaway");}
		
		public function powerTut1():String { return("Let's use a powerup!\n\nPress " + '"1"' + " at your keyboard to use 1st powerup.");}
		public function powerTut2():String { return("And let's try out another powerup!\n\nGuess what number at keyboard is responsible for powerup *number two*...");}
		public function firstStreak():String { return("This flower is the streak of 2 people:\n\n\n\n\n\n\nYou have to win two different guys in a row to complete a streak.\nWhen you lose you have to start from the 1st guy in the streak again.");}
		public function jptut():String { return("Hurray! You have opened jackpot and now you are be able to win it!\n\nYou have to defeat 8 different players in a row to win a jackpot.\n\nWhen you lose a game streak will be lost.\n\nGood luck!");}
		public function gofull():String { return("Let's go to the full story :)");}
		public function spiraltut():String { return('Congratulations on opening "Winnings Spiral"!\n\nIt contains all people you have defeated in any game.\n\nHave a look, you have some guys there already!');}		
		public function sutut():String { return("Drag matress on the lounge");}
		public function wstut():String { return("At this game you need to find words at that field.\n\nThey can be both horizontal and vertical (from left to right & from up to down).\n\n\n                        Here is a first one:\nSelect it with your mouse (like you select text)"); }
		public function tryOtherGames():String { return('Lets try out other games!\nSelect any game and click "Play" after that.'); };
		public function wtfstory1():String { return("Let's check out your way.");}
		public function wtfstory2_1():String { return('"My Way" is the new kind of "levels".\nWhat you see now is a tiny piece of the whole "Way", so plenty of fun awaits you!'); }
		public function wtfstory2_2_1():String { return("Every time you defeat somebody he(she) will be added in your way."); }
		public function wtfstory2_2_2():String { return('Have fun! Fill your "Winner' + "'" + 's Way" with victories!');}
		public function cool():String { return("Cool!");}
		
		public function wtf():String { return("Words to find: ");}
		public function friends():String { return("Friends");}
		public function toplabel():String { return("Top 100");}		
		
		public function shopname():String { return("Shop");}
		public function buy():String { return("Buy!"); }
		public function inpacks():String { return("Powerups in packs"); };
		public function unlimitedpowerups():String { return("Tickets for unlimited powerups"); };
		public function forAllGames():String { return("(for all games)"); };
		
		public function mystory():String { return("My Way");}
		public function nextlevel():String { return("Next level");}
		public function forwardlevel():String { return("Previous level");}
		
		public function myspiral():String { return("Spiral of Victories");}
		public function streakcolors():String { return("Streak colors");}
		public function andmore():String { return("(and more)");}	
		
		public function everywon():String { return("A tie!");}
		public function youwon():String { return("You won!");}
		public function wongame():String { return("won!");}
		public function showfull():String { return("Show full story");}
		public function postit():String { return("Post it");}
		public function toalbum():String { return("Add to album"); }
		public function existsAlready():String { return("already exists in your story"); };
		
		public function coinlogo():String { return("Add coins");}
		public function votes():String { return("FB Credits");}
		public function coinsname():String { return("Coins");}
		
		public function invite():String { return("Invite!");}
		public function invitetext():String { return("I invite you to play best realtime games with real people! Fill your Way with victories! Have fun, use powerups!");}
		public function uploadingphotos():String { return("Uploading photo...");}
		public function superText():String { return("Success!");}		
		public function error():String { return("Error occured.");}
		
		public function superbtn():String { return("Super!");}
		public function youwonjp():String { return("You won");}
		
		public function gotcha():String { return("Gotcha!");}
		public function justnow():String { return("just now");}
		
		public function usilyalok():String { return("powerups");}
		public function buying():String { return("Buying...");}		
		public function payerr():String { return("Payment error");}
		
		public function badword():String { return("is a bad word. Please, avoid using it.");}
		public function urn():String { return("urn");}
		
		public function dragme():String { return("Drag item");}
		
		public function uploaderror():String { return("Upload error");}
		public function mygamewith():String { return("My game with");}
		public function inwinnersway():String { return("in Winner's Way");}
		public function saveit():String { return("Save it!");}		
		public function ok():String { return("Okay!");}
		public function completed():String { return("completed");}
		public function of():String { return("of");}
		public function completedExcl():String { return("Completed!");}
		
		public function post():String { return("Okay");}
		public function permissionsgranted():String { return("Permissions applied"); }
		
		public function playWithAnyone():String { return("Play with anyone"); };
		public function playWithFriend():String { return("Play with friend"); };
		public function playWithFriendHeader():String { return("Send this link to your friend. Game will start when friend will follow it."); };
		public function playWithFriendNote():String { return("Note that this is one-time action and after you will start playing with friend switching game or starting a new one will be made with 1 click."); };
		public function playAgain():String { return("Play again"); };
		
		public function encourageInviting():String { return "We want to add more games and game modes (e.g. tournaments for 16, 32 people). But we can't do that because there is not enough players online to play them. Help us make game more interesting!" }
		public function helpInvite():String { return "I'll help (invite friends)" };
		public function wontHelpInvite():String { return "I won't help" };
		
		public function getWinMore(quantity:int):String
		{
			var result:String = "";
			if (quantity > 1) result = "win " + quantity + " more times to unlock";
			else result = "win one more game to unlock";
			return result;
		}
		
		public function getPowerupFullName(shortName:String):String
		{
			var fullName:String = "";
			if (shortName == "firstLetter") fullName = "First Letter";
			else if (shortName == "removeLetters") fullName = "-20 Letters";
			else if (shortName == "boost2x") fullName = "2x Booster";
			else if (shortName == "boost3x") fullName = "3x Booster";
			else if (shortName == "missile") fullName = "Self-guided missile";
			else if (shortName == "sevenMines") fullName = "Seven Mines";
			else if (shortName == "grid") fullName = "Show Grid";
			else if (shortName == "swapShape") fullName = "Swap Shape";
			else if (shortName == "nanoShape") fullName = "Tiny Ruby";
			else if (shortName == "undo") fullName = "Undo Turn";
			else if (shortName == "flyingbar") fullName = "Flying Bar";			
			return fullName;			
		}
		
		public function getPowerupDescription(powerupName:String):String
		{
			var description:String = "";
			if (powerupName == "firstLetter") description = "I'll show you first letter of random word from the list.";
			else if (powerupName == "removeLetters") description = "I'll remove 20 random letters, which are not included in any word.";
			else if (powerupName == "boost2x") description = "I'll boost your snake, so it will move twice as fast for 7 seconds.";
			else if (powerupName == "boost3x") description = "I'll boost your snake, so it will move 3 times faster for 7 seconds.";
			else if (powerupName == "missile") description = "I'll launch self-guided missile that'll knock out your enemy for 7 seconds.";
			else if (powerupName == "sevenMines") description = "I'll place 7 mines for your dear opponent.";
			else if (powerupName == "grid") description = "I'll show you a helping field grid.";
			else if (powerupName == "swapShape") description = "I'll change current shape for another one.";
			else if (powerupName == "nanoShape") description = "I'll give you a tiny ruby so you can fit it anywhere.";
			else if (powerupName == "undo") description = "I'll remove the shape your opponent placed at last turn.";
			else if (powerupName == "flyingbar") description = "I'll create a flying thingy that may be used for stacking things up.";
			return description;			
		}
		
		public function getWon(sex:int):String { return "won";}
		
		public function getInfinityText(duration:int):String
		{
			var result:String = "";
			if (duration == 1) result = "1 Day Ticket";
			else if (duration == 3) result = "3 Days Ticket";
			else if (duration == 7) result = "7 Days Ticket";
			else if (duration == 30) result = "30 Days Ticket";			
			return result;
		}
	}
}