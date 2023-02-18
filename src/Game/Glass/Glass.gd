extends StaticBody2D

var noise_scene = preload("res://src/Zones/AlertZone/AlertZone.tscn")

var is_broken: bool = false

func _ready():
	hide()
	
	$AnimatedSprite.animation = "normal"
	set_collision_layer_bit(12,true)
	
	get_tree().call_group("Detection","add_exception",self)

func destroy():
	$break.play()
	is_broken = true
	
	var noise = noise_scene.instance()
	noise.radius = 1000
	noise.time = 0.1
	Game.game_scene.add_child(noise)
	noise.global_position = global_position
	
	get_tree().call_group("Detection","remove_exception",self)	
	
	$AnimatedSprite.animation = "broken"
	set_collision_layer_bit(12,false)

func _on_VisibilityNotifier2D_screen_entered():
	show()

func _on_VisibilityNotifier2D_screen_exited():
	hide()
