extends StaticBody2D

signal bag_secured(bag_type)
signal player_escaped()

export var can_secure: bool = true
export var can_escape: bool = true

var is_player_in = false

var forbidden_bags = ["drill","guard","employee","civilian","manager"]


func _on_Secure_zone_area_entered(area):
	if (can_secure):
		if (area.get_parent().is_in_group("bags")):
			var bag = area.get_parent()
			if (!forbidden_bags.has(bag.bag_type)):
				bag.can_interact = false

				emit_signal("bag_secured",bag.bag_type)
				area.z_index = 0


func _on_Secure_zone_body_entered(body):
	if (body.name == "Player"):
		is_player_in = true
			
func _on_Secure_zone_body_exited(body):
	if (body.name == "Player"):
		is_player_in = false
		$Timer.stop()

func _process(delta):
	if (can_escape && is_player_in):
		if ($Timer.time_left <= 0):
			$Timer.start()
	else:
		$Timer.stop()

func _on_Timer_timeout():
	if (Game.player.health > 0):
		Game.game_process = false
		
		Game.map.end_heist()
		
		Game.game_scene.show_gamewin()
	

func _on_VisibilityNotifier2D_screen_entered():
	set_process(true)
	show()


func _on_VisibilityNotifier2D_screen_exited():
	set_process(false)	
	hide()
