extends KinematicBody2D

var speed = 500

var walkSpeed = 500
var runSpeed = 1000

var health = 0
var armor = 0
var stamina = 0

var current_weapon = -1

var weapons: Array = []

var can_switch_weapons = true

var weapon1_offset: Dictionary = {
	"stand":0,
	"interact":-10,
	"light":-10,
	"heavy":-30
}

var bag_offset: Dictionary = {
	"stand":0,
	"interact":-25,
	"light":-20,
	"heavy":-50
}

var velocity: Vector2 = Vector2.ZERO

func _ready():
	health = Game.player_max_health

	Game.player = self
	Game.player_status = Game.player_statuses.NORMAL

	$Bag.hide()
	$Player_sprite/dead.hide()

	calculate_speed("walk")

func calculate_speed(speedType: String):
	var armor_speed_penalty = 1
	var bag_speed_penalty = 1

	if (Game.player_bag != "empty"):
		if (Game.get_skill("commando",2,2) == "upgraded"):
			bag_speed_penalty = (1 - Global.bag_speed_penalties[Game.player_bag] * 0.5)
		else:
			bag_speed_penalty = (1 - Global.bag_speed_penalties[Game.player_bag])

	if (Game.player_armor != "Suit"):
		if (Game.get_skill("commando",3,2) == "upgraded"):
			armor_speed_penalty = (1 - Global.armor_values[Game.player_armor]["speed"] * 0.5)
		else:
			armor_speed_penalty = (1 - Global.armor_values[Game.player_armor]["speed"])

	if (armor_speed_penalty <= 0):
		armor_speed_penalty = 1

	if (bag_speed_penalty <= 0):
		bag_speed_penalty = 1

	print(str(armor_speed_penalty), " ", str(bag_speed_penalty))
	if (speedType == "walk"):
		speed = walkSpeed * (armor_speed_penalty * bag_speed_penalty)
	else:
		speed = runSpeed * (armor_speed_penalty * bag_speed_penalty)

func add_weapons():
	weapons.append(load(Global.weapon_scene_paths[Game.player_weapons[0]]).instance())
	add_child(weapons[0])
	move_child(weapons[0],0)
	weapons.append(load(Global.weapon_scene_paths[Game.player_weapons[1]]).instance())
	add_child(weapons[1])
	move_child(weapons[1],1)

func select_weapon(index: int) -> void:
	if (Game.player_can_shoot):
		if (index != current_weapon):
			current_weapon = index
		else:
			current_weapon = -1

		Game.player_weapon = current_weapon

		can_switch_weapons = false

		get_tree().create_timer(0.25).connect("timeout",self,"can_switch")

func can_switch():
	can_switch_weapons = true

func get_input() -> void:
	var mouse_pos = get_global_mouse_position()

	if (global_position.distance_to(mouse_pos) >  5 && !Game.player_is_interacting):
		look_at(mouse_pos)
		$Interaction_ray.look_at(mouse_pos)
		$Interaction_ray.force_raycast_update()

	var xDir = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	var yDir = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))

	if (!Game.player_is_interacting && !Game.player_is_meleing):
		if (Input.is_action_just_pressed("reload") && Game.player_can_shoot && current_weapon != -1):
			if (!Game.player_is_running || Game.get_skill("engineer",3,3) == "upgraded"):
				weapons[current_weapon].reload()

		if (Input.is_action_pressed("shoot") && Game.player_can_shoot && current_weapon != -1):
			weapons[current_weapon].shoot()

	if (!Game.player_is_interacting && !Game.player_is_reloading && !Game.player_is_meleing):
		if (Input.is_action_just_pressed("weapon1") && can_switch_weapons):
			select_weapon(0)
		elif (Input.is_action_just_pressed("weapon2") && can_switch_weapons):
			select_weapon(1)


		if (Input.is_action_pressed("melee") && Game.player_can_shoot && current_weapon != -1):
			weapons[current_weapon].melee()

		if (Input.is_action_just_pressed("drop") && Game.player_bag != "empty"):
			remove_bag()
			Game.spawn_bag()

		if (Input.is_action_just_pressed("switch_equipment")):
			switch_equipment()

		if (Input.is_action_just_pressed("use")):
			use_equipment()

		if (Input.is_action_pressed("sprint") && Game.player_can_run && stamina >= 10):
			use_stamina()
		elif (!Input.is_action_pressed("sprint") || !Game.player_can_run):
			recover_stamina()

	velocity = Vector2(xDir,yDir).normalized()

func switch_equipment() -> void:
	if ((range(Game.player_equipment.size()).has(1))):
		if (Game.player_current_equipment == 0 && Game.player_equipment[1][1] > 0):
			Game.player_current_equipment = 1
		elif (Game.player_equipment[0][1] > 0):
			Game.player_current_equipment = 0
	else:
		Game.player_current_equipment = 0

	if (Game.player_equipment[0][1] == 0):
		if ((range(Game.player_equipment.size()).has(1))):
			if (Game.player_equipment[1][1] == 0):
				Game.player_current_equipment = -1
		else:
			Game.player_current_equipment = -1

func use_medic_bag():
	if (Game.get_skill("mastermind",3,1) == "basic"):
		health = clamp(health + int(Game.player_max_health * 0.5),0,Game.player_max_health)
	elif (Game.get_skill("mastermind",3,1) == "upgraded"):
		health = clamp(health + int(Game.player_max_health * 0.85),0,Game.player_max_health)
	else:
		health = clamp(health + int(Game.player_max_health * 0.25),0,Game.player_max_health)

	if (Game.get_skill("mastermind",1,1) != "none"):
		walkSpeed *= 1.25
		runSpeed *= 1.25

		if (Game.get_skill("mastermind",1,1) == "upgraded"):
			Game.player_damage_reduction = 25

		var timer = Game.game_scene.get_node("Timers/Overdose")
		if (!timer.is_connected("timeout",self,"end_overdose_bonus")):
			timer.connect("timeout",self,"end_overdose_bonus")

		timer.start()

		Game.ui.show_timer("Overdose")

	Game.ui.do_green_effect()

func use_ammo_bag():
	weapons[current_weapon].current_mag_size = weapons[current_weapon].mag_size
	weapons[current_weapon].current_ammo_count = weapons[current_weapon].ammo_count

	if (Game.get_skill("commando",2,1) != "none"):
		weapons[0].current_mag_size = weapons[0].mag_size
		weapons[0].current_ammo_count = weapons[0].ammo_count

		weapons[1].current_mag_size = weapons[1].mag_size
		weapons[1].current_ammo_count = weapons[1].ammo_count

		if (Game.get_skill("commando",2,1) == "upgraded"):
			Game.is_bulletstorm_active = true
			Game.ui.show_timer("Bulletstorm")
			Game.game_scene.get_node("Timers/Bulletstorm").start()

	Game.ui.do_green_effect()

func end_overdose_bonus():
	Game.ui.hide_timer("Overdose")

	if Game.get_skill("infiltrator",1,2) != "none":
		walkSpeed = 500 * 1.25
		runSpeed = 1000 * 1.25
	else:
		walkSpeed = 500
		runSpeed = 1000

	Game.player_damage_reduction -= 25

	if (Game.player_damage_reduction < 0):
		Game.player_damage_reduction = 0

func hostage_taker():
	if (Game.get_skill("mastermind",4,2) == "basic"):
		health = clamp(health + health * 0.025,0,Game.player.max_health)
	else:
		health = clamp(health + health * 0.05,0,Game.player.max_health)

func push_it():
	var quarter_health = Game.player_max_health * 0.25
	var half_health = Game.player_max_health * 0.5
	var skill = Game.get_skill("engineer",4,3)

	if (skill == "basic" && health < quarter_health):
		health += (Game.player_max_health) * 0.015
		if (Game.player_armor != "Suit"):
			armor = clamp(armor + 100 * 0.015,0,100)
	elif (skill == "upgraded" && health < half_health):
		health += (Game.player_max_health) * 0.025

		if (Game.player_armor != "Suit"):
			armor = clamp(armor + 100 * 0.025,0,100)

	Game.push_it_cooldown = true
	Game.game_scene.get_node("Timers/PushIt").start()

func use_equipment() -> void:
	if (Game.player_current_equipment != -1 && Game.player_can_use_equipment):
		if (Game.player_equipment[Game.player_current_equipment][1] > 0):
			var name = Game.player_equipment[Game.player_current_equipment][0]
			Game.player_equipment[Game.player_current_equipment][1] -= 1

			if (name == "Medic Bag"):
				use_medic_bag()
			elif (name == "Ammo Bag" && current_weapon != -1):
				use_ammo_bag()
			elif (name == "C4"):
				var c4 = Game.scene_objects["c4"].instance()
				c4.radius = 500
				c4.damage = 300

				Game.game_scene.add_child(c4)
				c4.global_position = global_position
			elif (name == "ECM" && !Game.is_ecm_on):
				Game.activate_ecm()

			if (Game.player_equipment[Game.player_current_equipment][1] == 0):
				switch_equipment()

func use_stamina() -> void:
	if (stamina == 0):
		Game.player_can_run = false
		Game.player_is_running = false
		calculate_speed("walk")
		return

	elif (stamina > 0 && velocity != Vector2.ZERO):
		Game.player_is_running = true
		if ($Stamina_use.is_stopped()):
			$Stamina_use.start()

		$Stamina_recovery.stop()
		if (stamina > 0):
			calculate_speed("run")


func recover_stamina() -> void:
	if (stamina < Game.player_max_stamina):
		if ($Stamina_recovery.is_stopped()):
			$Stamina_recovery.start()
	else:
		$Stamina_recovery.stop()

	Game.player_is_running = false
	$Stamina_use.stop()

	calculate_speed("walk")

func _on_Stamina_use_timeout() -> void:
	if (Game.player_is_interacting || velocity == Vector2.ZERO):
		Game.player_can_run = false
		recover_stamina()
		return

	if (stamina > 0):
		stamina -= 1
	else:
		Game.player_can_run = false


func _on_Stamina_recovery_timeout() -> void:
	if (stamina < Game.player_max_stamina):
		stamina += 1

	if (stamina > 10 && velocity != Vector2.ZERO):
		Game.player_can_run = true

func _physics_process(delta) -> void:
	if (!Game.game_process || Game.player_is_dead):
		return

	get_input()

	#fix for a bug where player couldn't run after getting stuck in an object while running
	if (!Game.player_is_interacting && velocity != Vector2.ZERO && stamina > 0):
		Game.player_can_run = true

	if (!Game.player_is_interacting && Game.player_can_move):
		velocity = move_and_slide(velocity * speed)

func add_bag() -> void:
	$Bag.show()

func remove_bag() -> void:
	$Bag.hide()

func draw_player() -> void:
	if (Game.player_is_interacting):
		$Player_sprite.animation = Game.player_disguise + "_interact"
	elif (current_weapon != -1):
		if (current_weapon == 0):
			$Player_sprite.animation = Game.player_disguise + "_" + weapons[0].animation
		else:
			$Player_sprite.animation = Game.player_disguise + "_" + weapons[1].animation
	else:
		$Player_sprite.animation = Game.player_disguise + "_stand"

func draw_weapons() -> void:
	if (!Game.player_is_reloading && !Game.player_is_meleing):
		var plr_anim = $Player_sprite.animation.split("_")

		if (current_weapon == -1):
			if (weapons[0].is_weapon_visible):
				weapons[0].position = Vector2(-160 + weapon1_offset[plr_anim[1]],-15)
				weapons[0].rotation_degrees = 80
				weapons[0].show()
			else:
				weapons[0].hide()

			if (weapons[1].is_weapon_visible):
				weapons[1].position = Vector2(10,200)
				weapons[1].rotation_degrees = -15
				weapons[1].show()
			else:
				weapons[1].hide()

			move_child(weapons[0],0)
			move_child(weapons[1],1)
		elif (current_weapon == 0):
			weapons[0].position = weapons[0].weapon_position
			weapons[0].rotation_degrees = 0
			weapons[0].show()

			if (weapons[1].is_weapon_visible):
				weapons[1].position = Vector2(10,200)
				weapons[1].rotation_degrees = -15
				weapons[1].show()
			else:
				weapons[1].hide()

			move_child(weapons[0],get_child_count() - 1)
			move_child(weapons[1],0)
		elif (current_weapon == 1):
			if (weapons[0].is_weapon_visible):
				weapons[0].position = Vector2(-160 + weapon1_offset[plr_anim[1]],-15)
				weapons[0].rotation_degrees = 80
				weapons[0].show()
			else:
				weapons[0].hide()

			weapons[1].position = weapons[1].weapon_position
			weapons[1].rotation_degrees = 0
			weapons[1].show()

			move_child(weapons[0],0)
			move_child(weapons[1],get_child_count() - 1)

func draw_bag() -> void:
	if ($Bag.visible):
		var plr_anim = $Player_sprite.animation.split("_")

		$Bag.position = Vector2(-140 + bag_offset[plr_anim[1]],5)

func _process(delta) -> void:
	if (!Game.game_process || Game.player_is_dead):
		return

	if (current_weapon != -1):
		$Hostage_ray.enabled = true
	else:
		$Hostage_ray.enabled = false

	if (Game.is_game_loud):
		Game.player_status = Game.player_statuses.COMPROMISED
	elif (Game.suspicious_interaction):
		Game.player_status = Game.player_statuses.SUSPICIOUS
	elif (current_weapon != -1 || weapons[0].is_weapon_visible || weapons[1].is_weapon_visible || (Game.player_armor != "Suit" && Game.player_armor != "Light")):
		Game.player_status = Game.player_statuses.ARMED
	elif (Game.player_collision_zones.size() != 0):
		for zone in Game.player_collision_zones:
			if (!zone.disguises_needed.has(Game.player_disguise)):
				Game.player_status = Game.player_statuses.TRESPASSING
			else:
				if (Game.player_disguise != "normal"):
					Game.player_status = Game.player_statuses.DISGUISED
				else:
					Game.player_status = Game.player_statuses.NORMAL

		if (Game.player_status != Game.player_statuses.TRESPASSING):
			if (Game.player_disguise != "normal"):
				Game.player_status = Game.player_statuses.DISGUISED
			else:
				Game.player_status = Game.player_statuses.NORMAL
	else:
		if (Game.player_disguise != "normal"):
			Game.player_status = Game.player_statuses.DISGUISED
		else:
			Game.player_status = Game.player_statuses.NORMAL

	if (Game.player_status == Game.player_statuses.NORMAL):
		Game.add_exception(self)
	else:
		Game.remove_exception(self)

	draw_player()
	draw_weapons()
	draw_bag()

func take_damage(damage: float):
	var protection: float = Global.armor_values[Game.player_armor]["protection"]
	var durability: float = Global.armor_values[Game.player_armor]["durability"]
	var dodge: float = Global.armor_values[Game.player_armor]["dodge"]

	if (Game.get_skill("infiltrator",4,3) == "upgraded" && Game.is_ecm_on):
		dodge *= 3

	if (Game.get_skill("commando",1,2) != "none"):
		protection += 10
		if (Game.get_skill("commando",1,2) == "upgraded"):
			durability -= 2.5

	var chance: int = int(rand_range(1,100))
	var damage_total: float = damage - (damage * (Game.player_damage_reduction/100))

	if (Game.get_skill("commando",3,2) != "none"):
		if (Game.player_is_interacting):
			damage_total *= 0.5

	if (chance <= dodge):
		Game.ui.do_white_effect(0.25)
		return

	if (armor > 0):
		armor -= (durability * (0.25 * (Game.difficulty + 1)))

		if (protection > 0):
			damage_total -= damage_total * (protection / 100)

	Game.ui.do_red_effect(0.1)
	health -= damage_total

	if (health <= 0 && !Game.player_is_dead):
		weapons[0].hide()
		weapons[1].hide()

		$Player_sprite.animation = Game.player_disguise + "_stand"

		$Player_sprite/dead.show()
		Game.kill_player()
