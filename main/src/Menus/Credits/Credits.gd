extends Node2D

onready var menu_track: AudioStreamPlayer = Global.root.get_node("menu")

func _ready():
	$Control/CanvasLayer/Option_panel/RichTextLabel.scroll_to_line(0)


func _on_Back_btn_pressed():
	Composer.goto_scene(Global.scene_paths["mainmenu"],true,true,0.5,0.5,menu_track)
