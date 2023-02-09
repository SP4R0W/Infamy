extends RayCast2D


func _ready():
	pass

func _process(delta):
	if (is_colliding()):
		var collider = get_collider()
		
		if (collider.is_in_group("hitbox_npc")):
			var npc = collider.get_parent().get_parent()
			if (((npc.is_alerted && npc.npc_name != "guard") || !npc.is_alerted) && !npc.is_dead && !npc.is_unconscious && !npc.is_hostaged):
				npc.hostage()
