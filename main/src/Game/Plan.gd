extends VBoxContainer

var preplanning_info: Dictionary = {
	"bank":{
		"title":"Downtown Hit",
		"desc":"Like I said, this is a simple bank heist. You go in, look around, take out the security and open up that vault. Now, the place has cameras and security guards, so it's not THAT simple, but shouldn't be a problem for you. Try not to sound the alarm, I heard that the cops have way more men located in here, specifically to respond to people like us. So don't do anything stupid. Let's roll. ",
		"map":"res://src/Menus/Lobby/assets/map.png",
	}
}

func show():
	$Heist_title.text = preplanning_info[Game.level]["title"] + ": " + Game.difficulty_names[Game.difficulty]
	$Heist_plan.text = preplanning_info[Game.level]["desc"]
	
	.show()
