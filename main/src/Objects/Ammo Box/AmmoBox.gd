extends Area2D


func _ready():
	pass


func _on_Disappear_timeout():
	queue_free()


func _on_AmmoBox_body_entered(body):
	if (body.is_in_group("Player")):
		var weapon1_name = Game.player_weapons[0]
		var weapon2_name = Game.player_weapons[1]
		
		var ammo1: int = int(rand_range(Global.weapon_base_values[weapon1_name]["min_ammo_pickup"],Global.weapon_base_values[weapon1_name]["max_ammo_pickup"]))
		var ammo2: int = int(rand_range(Global.weapon_base_values[weapon2_name]["min_ammo_pickup"],Global.weapon_base_values[weapon2_name]["max_ammo_pickup"]))
		
		if (Game.get_skill("commando",1,1) != "none"):
			ammo1 += (ammo1 * 0.2)
			ammo2 += (ammo2 * 0.2)
		
		var weapon1 = Game.player.weapons[0]
		var weapon2 = Game.player.weapons[1]
		
		weapon1.current_ammo_count += ammo1
		if (weapon1.current_ammo_count > weapon1.ammo_count):
			weapon1.current_ammo_count = weapon1.ammo_count
	
		weapon2.current_ammo_count += ammo2
		if (weapon2.current_ammo_count > weapon2.ammo_count):
			weapon2.current_ammo_count = weapon2.ammo_count
		
		if (Game.get_skill("mastermind",2,2) == "upgraded"):
			var rand = randi() % 101
			if (rand <= 50):
				if (Game.handcuffs < Game.max_handcuffs):
					Game.handcuffs += 1
					
		queue_free()
