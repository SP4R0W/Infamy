extends Node2D

onready var menu_track: AudioStreamPlayer = Global.root.get_node("menu")

var max_volume: float = 6
var min_volume: float = -60

func _ready():
	$Control/CanvasLayer/HBoxContainer/Music/MusicText.text = "Music Volume: " + str(Savedata.music_volume)
	$Control/CanvasLayer/HBoxContainer/SFX/SfxText.text = "SFX Volume: " + str(Savedata.sfx_volume)

func _on_Back_btn_pressed():
	Composer.goto_scene(Global.scene_paths["mainmenu"],true,true,0.5,0.5,menu_track)


func _on_MusicSlider_drag_ended(value_changed):
	Savedata.music_volume = $Control/CanvasLayer/HBoxContainer/Music/MusicSlider.value
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),Savedata.music_volume)

	$Control/CanvasLayer/HBoxContainer/Music/MusicText.text = "Music Volume: " + str(Savedata.music_volume)


func _on_SfxSlider_drag_ended(value_changed):
	Savedata.sfx_volume = $Control/CanvasLayer/HBoxContainer/SFX/SfxSlider.value
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"),Savedata.sfx_volume)	
	
	$Control/CanvasLayer/HBoxContainer/SFX/SfxText.text = "SFX Volume: " + str(Savedata.sfx_volume)
