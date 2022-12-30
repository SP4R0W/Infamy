extends Panel

var preplanning_info: Dictionary = {
	"bank":{
		"title":"Downtown Hit",
		"desc":"Like I said, this is a simple bank heist. You go in, look around, take out the security and open up that vault. Now, the place has cameras and security guards, so it's not THAT simple, but shouldn't be a problem for you. Try not to sound the alarm, I heard that the cops have way more men located in here, specifically to respond to people like us. So don't do anything stupid. Let's roll. ",
		"map":"res://src/Menus/Lobby/assets/map.png",
		"default_track":"Razormind",
		"assets": {
			"medic":{
				
			}
		},
	}
}

func _ready():
	show_plan()

func show_plan() -> void:
	$Plan.show()
	$Assets.hide()
	$Gear.hide()
	$Music.hide()
	
	print(Game.level)
	
	$Plan/Heist_title.text = preplanning_info[Game.level]["title"] + ": " + Game.difficulty_names[Game.difficulty]
	$Plan/Heist_plan.text = preplanning_info[Game.level]["desc"]
	
	$Map.texture = load(preplanning_info[Game.level]["map"])

func show_assets() -> void:
	$Assets/Asset_desc/Title.text = "Select an asset"
	for child in $Assets/Asset_desc.get_children():
		if (child.name == "Title"):
			continue
			
		child.hide()
		
func _on_Plan_pressed() -> void:
	$Plan.show()
	$Assets.hide()
	$Gear.hide()
	$Music.hide()
	
	show_plan()

func _on_Assets_pressed() -> void:
	$Plan.hide()
	$Assets.show()
	$Gear.hide()
	$Music.hide()
	
	show_assets()

func _on_Gear_pressed() -> void:
	$Plan.hide()
	$Assets.hide()
	$Gear.show()
	$Music.hide()

func _on_Music_pressed() -> void:
	$Plan.hide()
	$Assets.hide()
	$Gear.hide()
	$Music.show()
