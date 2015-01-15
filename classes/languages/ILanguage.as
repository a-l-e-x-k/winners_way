package languages 
{
	
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public interface ILanguage 
	{
		function play():String;
		function jackpot():String;
		function mypowerups():String;
		function infinityExpires():String;
		function win():String;
		function more():String;
		function time():String;
		function time2():String;
		function toUnlock():String;
		function d():String;
		function h():String;
		function m():String;
		function coins():String;
		function ago():String;
		function beforeFinish():String;
		function beforeFinishStackup():String;
		function intro():String;
        function flower():String;
		
		function connecting():String;
		function loading():String;
		function findingopponent():String;
		function awaitingFriend():String;
		function connectingToFriend():String;
		
		function notenough():String;
		function cancel():String;
		function addCoins():String;
		function success():String;
		function add():String;
		
		function toWinjp():String;
		function descriptionJp():String;
		
		function st1():String;
		function st2():String;
		function st3():String;
		function st4():String;
		
		function sn1():String;
		function sn2():String;
		function sn3():String;
		
		function reeling():String;
		function asyncError():String;
		function yourTurn():String;
		function turnOf():String;	
		
		function ty():String;
		function giveaway():String;
		
		function powerTut1():String;
		function powerTut2():String;
		function firstStreak():String;
		function jptut():String;
		function gofull():String;
		function spiraltut():String;		
		function sutut():String;
		function wstut():String;
		function tryOtherGames():String;
		function wtfstory1():String;
		function wtfstory2_1():String;
		function wtfstory2_2_1():String;
		function wtfstory2_2_2():String;
		function cool():String;
		
		function wtf():String;
		function friends():String;
		function toplabel():String;		
		
		function shopname():String;
		function buy():String;
		function inpacks():String;
		function unlimitedpowerups():String;
		function forAllGames():String;
		
		function mystory():String;
		function nextlevel():String;
		function forwardlevel():String;
		
		function myspiral():String;
		function streakcolors():String;
		function andmore():String;	
		
		function everywon():String;
		function youwon():String;
		function wongame():String;
		function showfull():String;
		function postit():String;
		function toalbum():String;		
		function existsAlready():String;
		
		function coinlogo():String;
		function votes():String;
		function coinsname():String;
		
		function invite():String;
		function invitetext():String;
		function uploadingphotos():String;
		function superText():String;		
		function error():String;
		
		function superbtn():String;
		function youwonjp():String;
		
		function gotcha():String;
		function justnow():String;
		
		function usilyalok():String;
		function buying():String;		
		function payerr():String;
		
		function badword():String;
		function urn():String;
		
		function dragme():String;
		
		function uploaderror():String;
		function mygamewith():String;
		function inwinnersway():String;
		function saveit():String;		
		function ok():String;
		function completed():String;
		function of():String;
		function completedExcl():String;
		
		function post():String;
		function permissionsgranted():String;
		
		function getWinMore(quantity:int):String;
		function getPowerupFullName(shortName:String):String;
		function getPowerupDescription(powerupName:String):String;
		function getWon(sex:int):String;
		function getInfinityText(duration:int):String;
		
		function playWithAnyone():String;
		function playWithFriend():String;
		function playWithFriendHeader():String;
		function playWithFriendNote():String;
		function playAgain():String;
		
		function encourageInviting():String;
		function helpInvite():String;
		function wontHelpInvite():String;
	}	
}