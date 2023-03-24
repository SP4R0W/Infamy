extends Node2D

onready var menu_track: AudioStreamPlayer = Global.root.get_node("menu")

func _ready():
	if (!menu_track.playing):
		menu_track.play()
		
	if (Savedata.player_stats["needed_xp"] == 0):
		Global.calculate_needed_xp(1)
		
	$Control/CanvasLayer/Title_panel/VBoxContainer/Level.text = "Level: " + str(Savedata.player_stats["level"])
	$Control/CanvasLayer/Title_panel/VBoxContainer/Money.text = "Money: " + Global.format_str_commas(str(Savedata.player_stats["money"])) + "$"
	$Control/CanvasLayer/Title_panel/VBoxContainer/XP.text = "XP: " + Global.format_str_commas(str(Savedata.player_stats["cur_xp"])) + "/" + Global.format_str_commas(str(Savedata.player_stats["needed_xp"]))
	$Control/CanvasLayer/Title_panel/VBoxContainer/Points.text = "Skill points: " + str(Savedata.skill_loadouts[Savedata.player_stats["preffered_loadout"]]["skill_points"])
	
	$Control/CanvasLayer/Version/VersionText.text = "Version: " + str(Global.version)
	
	if (Savedata.player_stats["is_new"] && Savedata.player_stats["money"] < 1000):
		$Control/CanvasLayer/Welcome.show()
		$Control/CanvasLayer/Option_panel/VBoxContainer/Tutorial_btn.add_color_override("font_color",Color.webgreen)
	else:
		$Control/CanvasLayer/Welcome.hide()
		$Control/CanvasLayer/Option_panel/VBoxContainer/Tutorial_btn.add_color_override("font_color",Color.white)	
	
	if (Global.is_HTML):
		$Control/CanvasLayer/Option_panel/VBoxContainer/Exit_btn.hide()
	else:
		$Control/CanvasLayer/Option_panel/VBoxContainer/Exit_btn.show()


func _on_Exit_btn_pressed():
	get_tree().quit()

func _on_Online_btn_pressed():
	Composer.goto_scene(Global.scene_paths["lobby"],true,true,0.5,0.5,menu_track)


func _on_Credits_btn_pressed():
	Composer.goto_scene(Global.scene_paths["credits"],true,true,0.5,0.5,menu_track)

func _on_Help_btn_pressed():
	Composer.goto_scene(Global.scene_paths["help"],true,true,0.5,0.5,menu_track)


func _on_Inventory_btn_pressed():
	Composer.goto_scene(Global.scene_paths["inventory"],true,true,0.5,0.5,menu_track)


func _on_Settings_btn_pressed():
	Composer.goto_scene(Global.scene_paths["settings"],true,true,0.5,0.5,menu_track)


func _on_Skills_btn_pressed():
	Composer.goto_scene(Global.scene_paths["skills"],true,true,0.5,0.5,menu_track)


func _on_Tutorial_btn_pressed():
	Composer.goto_scene(Global.scene_paths["tutorial"],true,false,0.5,0.5,menu_track,false)
