extends StaticBody2D

var is_broken: bool = false

func _ready():
	hide()

	$AnimatedSprite.animation = "normal"
	set_collision_layer_bit(12,true)

	Game.add_exception(self)

func destroy():
	$break.play()
	is_broken = true

	var noise = Game.scene_objects["alert"].instance()
	Game.game_scene.call_deferred("add_child",noise)
		
	noise.radius = 1250
	noise.time = 0.1
	noise.global_position = global_position
		
	noise.start()

	Game.remove_exception(self)

	$AnimatedSprite.animation = "broken"
	call_deferred("set_collision_layer_bit",12,false)

func _on_VisibilityNotifier2D_screen_entered():
	show()

func _on_VisibilityNotifier2D_screen_exited():
	hide()
