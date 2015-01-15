$(document).ready(function()
{
	document.getElementById("play").onclick = function(){showTab("play")};
	document.getElementById("coins").onclick = function(){showTab("coins")};
	document.getElementById("help").onclick = function(){showTab("help")};
});

function showTab(tabName)
{	
	console.log(tabName);
	if (tabName != "play") //coins or help 
	{
		console.log(tabName);
		jQuery("#game").fadeTo(1, 0.001);
		jQuery("#game").animate({height:0}, 0.001);
		jQuery("#tabContent").load("https://winners-way-fb-rl3wvjarykcscflu8gjnxg.fb.playerio.com/fb/winners-way-fb-facebook-app/" + tabName + ".html", null, function(){$("#tabContent").show();});
		
	}
	else 
	{
		jQuery("#tabContent").hide();
		jQuery("#game").animate({height:631}, 0.001); //when doing fadeIn() / fadeOut() swf is being reloaded
		jQuery("#game").fadeTo(1000, 1);
	}
	
	jQuery("#tabs span").removeClass(); //remove "active" class
	jQuery(("#" + tabName)).addClass("active");	
}