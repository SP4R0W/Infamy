extends Node2D


func _ready():
	randomize()
	
	Composer.goto_scene(Global.scene_paths["mainmenu"],true,false,0.5,1)
	
