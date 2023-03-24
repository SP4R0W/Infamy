extends Node2D

onready var warning_panel = $Control/CanvasLayer/Warning

func _ready():
	# check if we're playing on a browser
	if (OS.get_name() == "HTML5"):
		Global.is_HTML = true
	
	# set a random seed for RNG
	randomize()
	
	# load data (or create new if it doesn't exist)
	Savedata.load_data()
	
	# set the volume
	if (!Savedata.player_settings.keys().has("master_volume")):
		Savedata.player_settings["master_volume"] = 100
		
	if (!Savedata.player_settings.keys().has("auto_reload")):
		Savedata.player_settings["auto_reload"] = true
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),linear2db(Savedata.player_settings["master_volume"]/100))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),linear2db(Savedata.player_settings["music_volume"]/100))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"),linear2db(Savedata.player_settings["sfx_volume"]/100))	
	
	# show fps counter if enabled
	check_fps()
	
	# get player skills
	Game.player_skills = Savedata.skill_loadouts[Savedata.player_stats["preffered_loadout"]]
	
	# go to main menu
	Composer.goto_scene(Global.scene_paths["mainmenu"],true,false,0.5,1)
	
func check_fps():
	if (Savedata.player_settings["fps"]):
		$Control/CanvasLayer/FPS.show()
		set_process(true)
	else:
		$Control/CanvasLayer/FPS.hide()
		set_process(false)
	
func _process(delta):
	$Control/CanvasLayer/FPS.text = "FPS: " + str(Engine.get_frames_per_second())
