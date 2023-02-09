extends Node2D


func _ready():
	if (OS.get_name() == "HTML5"):
		$Control/CanvasLayer/Option_panel/VBoxContainer/Exit_btn.hide()
	else:
		$Control/CanvasLayer/Option_panel/VBoxContainer/Exit_btn.show()


func _on_Exit_btn_pressed():
	get_tree().quit()

func _on_Online_btn_pressed():
	Composer.goto_scene(Global.scene_paths["lobby"],true,true,0.5,0.5)


func _on_Credits_btn_pressed():
	Composer.goto_scene(Global.scene_paths["credits"],true,true,0.5,0.5)

func _on_Help_btn_pressed():
	Composer.goto_scene(Global.scene_paths["help"],true,true,0.5,0.5)


func _on_Inventory_btn_pressed():
	Composer.goto_scene(Global.scene_paths["inventory"],true,true,0.5,0.5)
