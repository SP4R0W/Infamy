extends Node2D


func _ready():
	pass


func _on_Exit_btn_pressed():
	get_tree().quit()

func _on_Online_btn_pressed():
	Composer.goto_scene(Global.scene_paths["lobby"],true,true,0.5,0.5)
