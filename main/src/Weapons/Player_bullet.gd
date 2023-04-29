extends Area2D

export var damage: float = 10
export var type: String = ""

var accuracy: float
var spread: float

var velocity: Vector2 = Vector2(1,0)

var speed: float = 2000

var has_set_rotation: bool = false

func _ready():
	pass

func _physics_process(delta) -> void:
	if (!has_set_rotation):
		# Calculate bullet's spread when created
		var real_accuracy = ((100-accuracy)/100)
		if (Game.player.velocity == Vector2.ZERO || Game.get_skill("mastermind",1,3) == "upgraded"):
			spread = rand_range(-real_accuracy/4,real_accuracy/4)
		else:
			spread = rand_range(-real_accuracy/3,real_accuracy/3)

		has_set_rotation = true
		look_at(get_global_mouse_position())

	velocity.y = spread

	global_position += velocity.rotated(rotation) * speed * delta

func kill():
	queue_free()

func _on_VisibilityNotifier2D_screen_exited():
	kill()

func _on_Bullet_area_entered(area):
	if (area.is_in_group("shield")):

		var npc = area.get_parent().get_parent()
		if (type == "sniper"):
			if (Game.get_skill("mastermind",2,3) == "basic"):
				npc.take_damage(damage)
			elif (Game.get_skill("mastermind",2,3) == "upgraded"):
				npc.take_damage(damage*2)
			else:
				npc.take_damage(damage/2)
		else:
			if ((Game.get_skill("engineer",4,2) == "basic" && type == "automatic") || Game.get_skill("engineer",4,2) == "upgraded"):
				npc.take_damage(damage)
			else:
				npc.take_damage(damage * 0.35)
	kill()

func _on_Bullet_body_entered(body):
	if (body.is_in_group("glass")):
		if (!body.is_broken):
			body.destroy()
			kill()
		else:
			return
	elif (body.is_in_group("wood_door")):
		if (!body.is_broken && body.can_be_broken):
			body.destroy_door()
			kill()
		else:
			return
	else:
		kill()
