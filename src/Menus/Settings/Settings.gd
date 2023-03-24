extends Node2D

onready var menu_track: AudioStreamPlayer = Global.root.get_node("menu")

var music_per: float = 0
var sfx_per: float = 0

onready var music_label = $Control/CanvasLayer/VBoxContainer/HBoxContainer/Music/MusicText
onready var sfx_label = $Control/CanvasLayer/VBoxContainer/HBoxContainer/SFX/SfxText

onready var music_slider = $Control/CanvasLayer/VBoxContainer/HBoxContainer/Music/MusicSlider
onready var sfx_slider = $Control/CanvasLayer/VBoxContainer/HBoxContainer/SFX/SfxSlider

onready var master_slider = $Control/CanvasLayer/VBoxContainer/HBoxContainer/Master/MasterSlider
onready var master_label = $Control/CanvasLayer/VBoxContainer/HBoxContainer/Master/MasterText

var text_bools: Dictionary = {
	true:"on",
	false:"off"
}

func _ready():
	master_label.text = "Master Volume: " + str(Savedata.player_settings["master_volume"])
	music_label.text = "Music Volume: " + str(Savedata.player_settings["music_volume"])
	sfx_label.text = "SFX Volume: " + str(Savedata.player_settings["sfx_volume"])
	
	$Control/CanvasLayer/VBoxContainer/HBoxContainer2/Bodies/Body.text = "Dead Bodies: " + text_bools[Savedata.player_settings["dead_bodies"]]
	$Control/CanvasLayer/VBoxContainer/HBoxContainer2/Subtitles/Subtitle.text = "Bain's lines: " + text_bools[Savedata.player_settings["subtitles"]]
	$Control/CanvasLayer/VBoxContainer/HBoxContainer2/Reload/Reload.text = "Auto Reload: " + text_bools[Savedata.player_settings["auto_reload"]]

	master_slider.value = Savedata.player_settings["master_volume"]
	music_slider.value = Savedata.player_settings["music_volume"]
	sfx_slider.value = Savedata.player_settings["sfx_volume"]

	if (Savedata.player_settings["fps"]):
		$Control/CanvasLayer/VBoxContainer/HBoxContainer3/FPS/FPS.text = "Hide FPS"
	else:
		$Control/CanvasLayer/VBoxContainer/HBoxContainer3/FPS/FPS.text = "Show FPS"
		
	if (!Savedata.player_settings.has("timers")):
		Savedata.player_settings["timers"] = true
		
	if (Savedata.player_settings["timers"]):
		$Control/CanvasLayer/VBoxContainer/HBoxContainer3/Timers/Timers.text = "Hide Timers"
	else:
		$Control/CanvasLayer/VBoxContainer/HBoxContainer3/Timers/Timers.text = "Show Timers"
		
	$Control/CanvasLayer/VBoxContainer/HBoxContainer4.show()

func _on_Back_btn_pressed():
	Savedata.save_data()
	Composer.goto_scene(Global.scene_paths["mainmenu"],true,true,0.5,0.5,menu_track)

func _on_MasterSlider_drag_ended(value_changed):
	Savedata.player_settings["master_volume"] = master_slider.value
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"),linear2db(Savedata.player_settings["master_volume"]/100))

	master_label.text = "Master Volume: " + str(master_slider.value)

func _on_MusicSlider_drag_ended(value_changed):
	Savedata.player_settings["music_volume"] = music_slider.value
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"),linear2db(Savedata.player_settings["music_volume"]/100))

	music_label.text = "Music Volume: " + str(music_slider.value)


func _on_SfxSlider_drag_ended(value_changed):
	Savedata.player_settings["sfx_volume"] = sfx_slider.value
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"),linear2db(Savedata.player_settings["sfx_volume"]/100))

	sfx_label.text = "SFX Volume: " + str(sfx_slider.value)


func _on_Body_pressed():
	Savedata.player_settings["dead_bodies"] = !Savedata.player_settings["dead_bodies"]
	$Control/CanvasLayer/VBoxContainer/HBoxContainer2/Bodies/Body.text = "Dead Bodies: " + text_bools[Savedata.player_settings["dead_bodies"]]



func _on_Subtitle_pressed():
	Savedata.player_settings["subtitles"] = !Savedata.player_settings["subtitles"]
	$Control/CanvasLayer/VBoxContainer/HBoxContainer2/Subtitles/Subtitle.text = "Bain's lines: " + text_bools[Savedata.player_settings["subtitles"]]

func _on_Reload_pressed():
	Savedata.player_settings["auto_reload"] = !Savedata.player_settings["auto_reload"]
	$Control/CanvasLayer/VBoxContainer/HBoxContainer2/Reload/Reload.text = "Auto Reload: " + text_bools[Savedata.player_settings["subtitles"]]

func _on_Reset_pressed():
	var button = $Control/CanvasLayer/VBoxContainer/HBoxContainer5/Restart/Reset
	if (button.text == "Reset Progress"):
		button.text = "Are you sure? Press again."
	elif (button.text == "Are you sure? Press again."):
		button.text = "Progress reset!"
		Savedata.reset_progress()
	else:
		button.text = "Reset Progress"


func _on_FPS_pressed():
	Savedata.player_settings["fps"] = !Savedata.player_settings["fps"]
	if (Savedata.player_settings["fps"]):
		$Control/CanvasLayer/VBoxContainer/HBoxContainer3/FPS/FPS.text = "Hide FPS"
	else:
		$Control/CanvasLayer/VBoxContainer/HBoxContainer3/FPS/FPS.text = "Show FPS"
	
	Global.root.check_fps()

func _on_Timers_pressed():
	Savedata.player_settings["timers"] = !Savedata.player_settings["timers"]
	if (Savedata.player_settings["timers"]):
		$Control/CanvasLayer/VBoxContainer/HBoxContainer3/Timers/Timers.text = "Hide Timers"
	else:
		$Control/CanvasLayer/VBoxContainer/HBoxContainer3/Timers/Timers.text = "Show Timers"






