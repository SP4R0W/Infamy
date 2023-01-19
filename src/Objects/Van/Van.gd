extends StaticBody2D

signal bag_secured(bag_type)
signal player_escaped()

export var can_secure: bool = true
export var can_escape: bool = true

var forbidden_bags = ["drill"]

func _ready():
	pass


func _on_Secure_zone_area_entered(area):
	if (can_secure):
		if (area.get_parent().is_in_group("bags")):
			var bag = area.get_parent()
			if (!forbidden_bags.has(bag.bag_type) && !bag.has_disguise):
				bag.can_interact = false

				emit_signal("bag_secured",bag.bag_type)


func _on_Secure_zone_body_entered(body):
	if (can_escape):
		if (body.is_in_group("Player")):
			if ($Timer.wait_time <= 0):
				$Timer.start()
			
func _on_Secure_zone_body_exited(body):
	if (can_escape):
		if (body.is_in_group("Player")):
			$Timer.stop()

func _on_Timer_timeout():
	Game.can_process = false
	Game.game_scene.show_gamewin()
	



