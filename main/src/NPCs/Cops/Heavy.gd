extends NPC

onready var agent: NavigationAgent2D = $NavigationAgent2D

var weapon_stats: Dictionary = {
	"LMG":{
		"texture":"res://src/Weapons/UZI/assets/uzi.png",
		"firerate":0.3,
		"reload_time":4,
		"mag_size":50,
		"damage":1.5,
		"position":Vector2(160,100)
	}
}

export(String, "LMG") var weapon_name = "LMG"
var weapon_mag = 0

var has_path = false

var speed = 300
var velocity: Vector2 = Vector2.ZERO

var whitedeath_can_deal_damage = false
var whitedeath_damage = 0

func on_ready():
	speed = 300 + (33 * Game.difficulty)
	
	$AnimatedSprite.animation = "shoot"

	$AnimatedSprite/Weapon.texture = load(weapon_stats[weapon_name]["texture"])
	$AnimatedSprite/Weapon.position = weapon_stats[weapon_name]["position"]
	
	$Shoot_timer.wait_time = weapon_stats[weapon_name]["firerate"]
	$ReloadTimer.wait_time = weapon_stats[weapon_name]["reload_time"]
	
	weapon_mag = weapon_stats[weapon_name]["mag_size"]
	damage = weapon_stats[weapon_name]["damage"] * (Game.difficulty + 1)
	
	yield(get_tree().create_timer(0.5),"timeout")
	
	if (Game.map_nav != null):
		agent.set_navigation(Game.map_nav)

	.on_ready()
	
func on_physics_process(delta):
	if (!Game.game_process):
		return
		
	if (!has_path && !is_dead):
		if (global_position.distance_to(Game.player.global_position) > 300):
			has_path = true
			agent.set_target_location(Game.player.global_position)
			is_moving = true
	elif (has_path && is_moving && !is_dead):
		if (Game.difficulty < 3 && is_shooting):
			return
		else:		
			var point = agent.get_final_location()
			
			if (Game.player.global_position.distance_to(point) >= 300):
				agent.set_target_location(Game.player.global_position)
			
			if (global_position.distance_to(point) <= 300):
				is_moving = false
				has_path = false
			
			if (!is_shooting):
				$AnimatedSprite.look_at(agent.get_next_location())
			
			var dir = global_position.direction_to(agent.get_next_location())
			
			var r_speed = speed
			
			var desired = dir * r_speed
			var steering = (desired - velocity) * delta * 4
			velocity += steering
			
			if (soft.is_colliding()):
				velocity += soft.get_push_vector() * delta * 400
			
			global_position += velocity * delta
				
	.on_physics_process(delta)
	
func shoot(target,damage):
	weapon_mag -= 1
	if (weapon_mag <= 0):
		can_shoot = false
		$ReloadTimer.start()
	
	.shoot(target,damage)

func kill(damage: float = 0,type: String = "none"):
	if (!is_dead):
		$AnimatedSprite/Weapon.texture = null
		$AnimatedSprite.animation = "dead"
		
		has_path = false
		is_moving = false
		
		Game.current_cops -= 1
		Game.kills += 1
		
		if (Game.current_cops == 0 && Game.map.is_wave_break):
			Game.map._on_WaveTimer_timeout()
		
		if (Game.get_skill("mastermind",3,3) != "none" && type == "sniper"):
			var timer = Game.game_scene.get_node("Timers/Desperado")
			if (timer.time_left <= 0):
				timer.start()
				Game.desperado_kill_counter += 1
			else:
				Game.desperado_kill_counter += 1
			
			if (Game.get_skill("mastermind",3,3) == "basic"):
				if (Game.desperado_kill_counter >= 4):
					timer.stop()
					Game.desperado_active = true
					Game.desperado_kill_counter = 0
			elif (Game.get_skill("mastermind",3,3) == "upgraded"):
				if (Game.desperado_kill_counter >= 3):
					timer.stop()
					Game.desperado_active = true
					Game.desperado_kill_counter = 0
					
					Game.player.weapons[0].current_mag_size += 1
					if (Game.player.weapons[0].current_mag_size > Game.player.weapons[0].mag_size):
						Game.player.weapons[0].current_mag_size = Game.player.weapons[0].mag_size
		elif (Game.get_skill("engineer",3,3) != "none" && type == "automatic"):
			var timer = Game.game_scene.get_node("Timers/LocknLoad")
			if (timer.time_left <= 0):
				timer.start()

			Game.locknload_kill_counter += 1
				
			if (Game.locknload_kill_counter >= 2 && !Game.locknload_active):
				Game.locknload_active = true
				Game.locknload_kill_counter = 0
		elif (Game.get_skill("commando",4,3) != "none" && type == "shotgun"):
			var timer = Game.game_scene.get_node("Timers/Golden2")
			if (timer.time_left <= 0):
				timer.start()

			Game.golden_kill_counter += 1
				
			if (Game.golden_kill_counter >= 2 && !Game.golden_active):
				Game.game_scene.get_node("Timers/Golden").start()
				Game.ui.show_timer("Golden")
				
				Game.golden_active = true
				Game.golden_kill_counter = 0
		
		if (Game.get_skill("mastermind",4,3) != "none" && type == "sniper"):
			whitedeath_can_deal_damage = true
			whitedeath_damage = damage
			$AnimatedSprite/WhiteDeath/CollisionShape2D.set_deferred("disabled",false)
			Game.create_temp_timer(1,self,"whitedeath_end")
		
		if (Game.get_skill("commando",4,2) == "upgraded" && !Game.unbreakable_cooldown && Game.player_armor != "Suit"):
			Game.player.armor += (100 * 0.025)
			Game.unbreakable_cooldown = true
			Game.game_scene.get_node("Timers/Unbreakable").start()
		
		.kill(damage,type)

func take_damage(damage: float,type: String = "none"):
	if (type == "sniper" && Game.get_skill("mastermind",2,3) == "upgraded"):
		health -= (damage * 2)
	elif (type == "automatic" && Game.get_skill("engineer",2,3) == "upgraded"):
		health -= (damage * 1.2)
	elif ((type == "shotgun" && Game.get_skill("commando",4,3) != "none") || Game.get_skill("commando",4,3) == "upgraded"):
		health -= (damage * 1.5)
	else:
		if (health > 100):
			health -= (damage * 0.25)
		else:
			health -= (damage * 0.85)
		
	if (health <= 0):
		kill()
	
	.take_damage(damage,type)

func _on_ReloadTimer_timeout():
	weapon_mag = weapon_stats[weapon_name]["mag_size"]
	can_shoot = true

func whitedeath_end():
	whitedeath_can_deal_damage = false
	$AnimatedSprite/WhiteDeath/CollisionShape2D.set_deferred("disabled",true)

func _on_WhiteDeath_area_entered(area):
	if (area.is_in_group("hitbox_npc")):
		var npc = area.get_parent().get_parent()

		if (npc.npc_name == "cop" && whitedeath_can_deal_damage):
			if (Game.get_skill("mastermind",4,3) == "basic"):
				npc.take_damage(whitedeath_damage/2)
			else:
				npc.take_damage(whitedeath_damage)
