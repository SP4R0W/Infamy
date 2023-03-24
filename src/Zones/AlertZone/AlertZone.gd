extends Area2D

export var type = ""
export var radius: float = 500 setget radius_set
export var time: float = 2

onready var col_shape: CollisionShape2D = $CollisionShape2D

var can_alert = false

func radius_set(new_value):
	radius = new_value

	var circle = CircleShape2D.new()
	
	if (Game.get_skill("engineer",3,1) != "none" && type == "drill"):
		circle.radius = radius * 0.5
	elif (Game.get_skill("engineer",3,2) == "upgraded" && type == "c4_object"):
		circle.radius = radius * 0.85
	else:
		circle.radius = radius

	$CollisionShape2D.set_deferred("shape",circle)

func _ready():
	var circle = CircleShape2D.new()
	circle.radius = radius
	
	$CollisionShape2D.set_deferred("shape",circle)
	
func start():
	$CollisionShape2D.set_deferred("disabled",false)
	can_alert = true
	
	if (time > 0):
		Game.create_temp_timer(time,self,"_on_Timer_timeout")

func _on_AlertZone_area_entered(area):
	if (area.is_in_group("hitbox_npc")):
		var npc = area.get_parent().get_parent()
		if (!npc.is_dead && !npc.is_unconscious && !npc.is_hostaged && !npc.is_escaping && !npc.is_alerted && can_alert):
			npc.noise_heard()

func pause():
	can_alert = false
	$CollisionShape2D.set_deferred("disabled",true)
	
func unpause():
	can_alert = true
	$CollisionShape2D.set_deferred("disabled",false)
	
func remove():
	queue_free()

func _on_Timer_timeout():
	can_alert = false
	queue_free()
