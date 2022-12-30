extends Area2D

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
		spread = rand_range(-real_accuracy/2,real_accuracy/2)
		print(spread)
		
		look_once = false
		look_at(get_global_mouse_position())
		
	velocity.y = spread
		
	global_position += velocity.rotated(rotation) * speed * delta

func kill():
	queue_free()

func _on_VisibilityNotifier2D_screen_exited():
	kill()

func _on_Bullet_area_entered(area):
	kill()

func _on_Bullet_body_entered(body):
	if (body.is_in_group("glass")):
		body.destroy()
	
	kill()