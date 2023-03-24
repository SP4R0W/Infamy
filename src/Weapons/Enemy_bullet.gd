extends Area2D

export var damage: float = 10

var target = null

var accuracy: float
var spread: float

var velocity: Vector2 = Vector2(1,0)

var speed: float = 2000

var look_once: bool = true

func _ready():
	pass

func _physics_process(delta) -> void:
	if (look_once):
		var real_accuracy = ((100-accuracy)/100)
		if (Game.player.velocity == Vector2.ZERO):
			spread = rand_range(-real_accuracy/2,real_accuracy/2)
		else:
			spread = rand_range(-real_accuracy,real_accuracy)

		look_once = false
		look_at(target.global_position)

		
	velocity.y = spread
		
	global_position += velocity.rotated(rotation) * speed * delta

func kill():
	queue_free()

func _on_VisibilityNotifier2D_screen_exited():
	kill()

func _on_Enemy_bullet_area_entered(area):
	kill()

func _on_Enemy_bullet_body_entered(body):
	if (body.is_in_group("glass")):
		if (!body.is_broken):
			body.destroy()
			kill()
		else:
			return
	elif (body.is_in_group("wood_door")):
		if (!body.is_broken):
			body.destroy_door()
			kill()
		else:
			return
	elif (body.is_in_group("Player")):
		body.take_damage(damage)
		
	else:
		kill()
