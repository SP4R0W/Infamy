extends Area2D

export var radius: float = 500
export var time: float = 2

onready var col_shape: CollisionShape2D = $CollisionShape2D

func _ready():
	var circle = CircleShape2D.new()
	circle.radius = radius
	col_shape.shape = circle
	col_shape.disabled = true
	
	if (time > 0):
		col_shape.disabled = false
		
		yield(get_tree().create_timer(time),"timeout")
	
		queue_free()


func _on_AlertZone_area_entered(area):
	if (area.is_in_group("hitbox_npc")):
		var npc = area.get_parent().get_parent()
		if (!npc.is_dead && !npc.is_unconscious && !npc.is_hostaged && !npc.is_escaping && !npc.is_alerted):
			npc.noise_heard()

func pause():
	col_shape.disabled = true
	
func unpause():
	col_shape.disabled = false
	
func remove():
	queue_free()
