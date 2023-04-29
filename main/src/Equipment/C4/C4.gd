extends Sprite

export var radius: float = 500 setget radius_set
export var damage: float = 300

var has_been_activated = false

var can_kill = true

func _ready():
	pass

func radius_set(new_value):
	radius = new_value

	var explosion_circle = CircleShape2D.new()

	if (Game.get_skill("engineer",1,2) != "none"):
		explosion_circle.radius = radius * 1.5

		var detection_circle = CircleShape2D.new()
		detection_circle.radius = 300

		$Detect/CollisionShape2D.set_deferred("shape",detection_circle)
	else:
		explosion_circle.radius = radius

	$Explosion/CollisionShape2D.set_deferred("shape",explosion_circle)

func _on_Explosion_area_entered(area:Area2D):
	# Kill every NPC that enters the explosion area
	if (area.is_in_group("hitbox_npc") && can_kill):
		if (Game.get_skill("engineer",1,2) == "upgraded"):
			area.get_parent().get_parent().take_damage(damage*1.5)
		else:
			area.get_parent().get_parent().take_damage(damage)

func _on_VisibilityNotifier2D_screen_exited():
	hide()

func _on_VisibilityNotifier2D_screen_entered():
	show()

func _on_Detect_area_entered(area):
	if (area.is_in_group("hitbox_npc") && !has_been_activated):
		has_been_activated = true

		var noise = Game.scene_objects["alert"].instance()
		Game.game_scene.call_deferred("add_child",noise)

		noise.radius = 4000
		noise.time = 0.1

		noise.global_position = global_position

		noise.start()

		$Explosion/CollisionShape2D.set_deferred("disabled",false)

		$ExplosionSound.play()

		can_kill = true

		Game.create_temp_timer(2,self,"kill")

func kill():
	can_kill = false
	call_deferred("queue_free")


