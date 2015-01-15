// this array will contain a list of functions that will be called when facebook is fully loaded and user is logged in.
var onFacebookAvailable = [];
// will execute all queued up methods.
function runOnFacebookAvailable()
{
	console.log(onFacebookAvailable.length);
	for (var i = 0; i != onFacebookAvailable.length; i++) 
	{
		var cb = onFacebookAvailable[i];
		cb();
	}
}

function makeRequestCheck()
{
  console.log(document.location.href);
  if (document.location.href.indexOf("request_ids") != -1) //user came via request. deleting requests
  {
	  var finishIndex = document.location.href.indexOf("&") == -1 ? document.location.href.length : document.location.href.indexOf("&");
	  var requestIDs = document.location.href.substring(document.location.href.indexOf("=") + 1, finishIndex); //extract all the request string, beginning from requests ids start
	  console.log(requestIDs);
	  var idsArray = requestIDs.split("%2C"); //%2c = ","
	  console.log(idsArray);
	  for (var i = 0; i < idsArray.length; i++) //ask FB to remove IDs
	  {
		  var id = new Number();
		  id = idsArray[i];
		  FB.api(id, 'delete', function(response) {
		  console.log(response);
		  });
	  }
  };			
}

function createSWF()
{
	$(document).ready(function(e) {
		$("#game").show(); //it will pass all template variables to swf. Now Facebook connection is established.
		$("#game").removeClass("hidden");		
    });		
}

function showFriendInviter ()
{		
	console.log("showFriendInviter");
	document.getElementById("invFriends").onclick = null;
	FB.ui({method: 'apprequests',
		message: 'I invite you to play realtime games with social story!',
		filters:["app_non_users"],
		title:"Invite friends"					
	}, requestCallback);
	
	function requestCallback()
	{
		document.getElementById("invFriends").onclick = showFriendInviter;
	};
};