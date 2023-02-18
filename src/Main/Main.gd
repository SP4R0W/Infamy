extends Node2D


func _ready():
	if (OS.get_name() == "HTML5"):
		Global.is_HTML = true
	
	randomize()
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),Savedata.music_volume)	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"),Savedata.sfx_volume)	
	
	Composer.goto_scene(Global.scene_paths["mainmenu"],true,false,0.5,1)
	
func _process(delta):
	$Control/CanvasLayer/FPS.text = "FPS: " + str(Engine.get_frames_per_second())
