extends StaticBody2D

signal bag_secured(bag_type)
signal player_escaped()

export var can_secure: bool = true
export var can_escape: bool = true

var forbidden_bags = ["drill"]


func _on_Secure_zone_area_entered(area):
	if (can_secure):
		if (area.get_parent().is_in_group("bags")):
			var bag = area.get_parent()
			if (!forbidden_bags.has(bag.bag_type) && !bag.has_disguise):
				bag.can_interact = false

				emit_signal("bag_secured",bag.bag_type)
				area.z_index = 0


func _on_Secure_zone_body_entered(body):
	if (can_escape):
		if (body.name == "Player"):
			if ($Timer.time_left <= 0):
				print("escape started")
				$Timer.start()
			
func _on_Secure_zone_body_exited(body):
	if (can_escape):
		if (body.name == "Player"):
			$Timer.stop()

func _on_Timer_timeout():
	Game.game_process = false
	Game.game_scene.show_gamewin()
	



