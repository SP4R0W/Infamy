extends Area2D

export var disguises_needed = ["employee","guard"]

func _on_LevelZone_body_entered(body):
	if (body.is_in_group("Player")):
		Game.player_collision_zones.append(self)


func _on_LevelZone_body_exited(body):
	if (body.is_in_group("Player")):
		Game.player_collision_zones.erase(self)
