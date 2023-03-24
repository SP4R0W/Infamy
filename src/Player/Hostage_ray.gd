extends RayCast2D

var check_done = false

func _process(delta):
	if (!Game.game_process):
		return
	
	if (!check_done):
		check_done = true
		if (Game.get_skill("mastermind",2,2) != "none"):
			cast_to = Vector2(1000,0)
		else:
			cast_to = Vector2(500,0)
	
		force_raycast_update()
	
	if (is_colliding()):
		var collider = get_collider()
		
		if (collider.is_in_group("hitbox_npc")):
			var npc = collider.get_parent().get_parent()
			if (((npc.is_alerted && npc.npc_name != "guard") || !npc.is_alerted) && !npc.is_dead && !npc.is_unconscious && !npc.is_hostaged):
				npc.hostage()
