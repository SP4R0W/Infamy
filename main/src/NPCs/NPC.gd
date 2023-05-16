extends Node2D
class_name NPC

signal object_interaction_started(object)
signal object_interaction_aborted(object)
signal object_interaction_finished(object)

signal npc_hostaged(object)
signal npc_interrogated(object)
signal npc_knocked(object)
signal npc_dead(object)

signal alerted(code)

export var health: float = 10
export var initial_rotation: float = 0
export var npc_name: String

export var can_interact: bool = false
export var has_second_interaction: bool = false
export var has_third_interaction: bool = false
export var can_see: bool = true
export var can_detect: bool = true
export var can_escape: bool = true
export var can_knock: bool = true
export var can_bag: bool = true
export var what_can_see: Dictionary = {
	"Player":{
		"detection_value_normal":2.5,
		"detection_value_disguised":1.2,
		"code": "_player"
	},
	"npc":{
		"detection_value_normal":3,
		"code_body": "_body",
		"code_alarm": "_alert",
		"code_hostage": "_hostage"
	},
	"bags":{
		"detection_value_normal":3,
		"code": "_bag"
	},
	"door":{
		"detection_value_normal":3,
		"code": "_door"
	},
	"glass":{
		"detection_value_normal":3,
		"code": "_glass"
	},
	"Camera":{
		"detection_value_normal":3,
		"code": "_camera"
	},
	"drill":{
		"detection_value_normal":3,
		"code": "_drill"
	}
}
export var has_weapon: bool = false

export var info: String = "none"

export var is_dead: bool = false
export var is_unconscious: bool = false
export var is_hostaged: bool = false
export var is_tied_hostage: bool = false
export var is_alerted: bool = false
export var has_disguise: bool = true
export var has_penalty: bool = false

onready var move_timer: Timer = $MoveTimer
onready var rays: Node2D = $AnimatedSprite/Raycasts
onready var soft = $AnimatedSprite/SoftCollision

var damage: float = 0

var action: String = "loop"

var has_focus: bool = false

var deffered_targets = []
var targets = {}

var detection_code: String = "None"
var detection_value: int = 0

var is_detecting: bool = false

var can_shoot: bool = true
var is_shooting: bool = false

var was_interrogated: bool = false

var is_following: bool = false
var is_escaping: bool = false
var is_moving: bool = false

var fov_polygons: Array = [
	PoolVector2Array([Vector2(55,-40),Vector2(1000,-900),Vector2(1000,900),Vector2(55,40)]),
	PoolVector2Array([Vector2(55,-40),Vector2(1250,-900),Vector2(1250,900),Vector2(55,40)]),
	PoolVector2Array([Vector2(55,-60),Vector2(1500,-1100),Vector2(1500,1100),Vector2(55,60)]),
	PoolVector2Array([Vector2(55,-75),Vector2(1750,-1250),Vector2(1750,1250),Vector2(55,75)]),
]

func _ready():
	connect("alerted",Game,"turn_game_loud")

	$Marker.hide()
	$Detection_bar.hide()
	$Interaction_panel.hide()
	$Interaction_panel/VBoxContainer/Interaction_progress.hide()
	$Interaction_panel/VBoxContainer/Action1.hide()
	$Interaction_panel/VBoxContainer/Action2.hide()
	$Interaction_panel/VBoxContainer/Action3.hide()

	$AnimatedSprite.rotation_degrees = initial_rotation

	draw_fov()

	on_ready()

	Game.add_exception($Interaction_hitbox)

func draw_fov():
	if (Game.difficulty != 4):
		$AnimatedSprite/Detect/CollisionPolygon2D.polygon = fov_polygons[Game.difficulty]
	else:
		$AnimatedSprite/Detect/CollisionPolygon2D.polygon = fov_polygons[3]

func on_ready():
	pass

func show_panel():
	has_focus = true
	$Interaction_panel.show()
	$Interaction_panel/VBoxContainer/Interaction_progress.hide()

func hide_panel():
	has_focus = false
	$Interaction_panel.hide()

func _on_Interaction_timer_timeout():
	finish_interactions()

func create_ray() -> RayCast2D:
	var ray = RayCast2D.new()
	ray.cast_to = Vector2(2200,0)
	ray.collide_with_areas = true
	ray.collide_with_bodies = true
	ray.enabled = false
	ray.exclude_parent = true
	ray.set_collision_mask_bit(0,true)
	ray.set_collision_mask_bit(3,true)
	ray.set_collision_mask_bit(12,true)
	ray.set_collision_mask_bit(15,true)

	ray.add_exception($Interaction_hitbox)

	for exception in Game.exceptions:
		if (is_instance_valid(exception)):
			ray.add_exception(exception)
		else:
			Game.remove_exception(exception)

	rays.add_child(ray)

	return ray

func set_npc_interactions():
	if (!can_interact):
		return


func check_interactions():
	pass

func finish_interactions():
	pass

func on_physics_process(delta: float):
	pass

func _physics_process(delta):
	if (!Game.game_process):
		return

	if (can_detect && !is_alerted && !is_dead && !is_unconscious && !is_hostaged && !is_escaping && npc_name != "cop"):
		for t in targets.keys():
			if (Game.exceptions.has(t)):
				if (targets[t] != null):
					targets[t].queue_free()

				targets.erase(t)
				deffered_targets.append(t)
				continue

			if (targets[t] == null):
				targets[t] = create_ray()

			var ray = targets[t]

			ray.look_at(t.global_position)
			ray.cast_to = Vector2($AnimatedSprite.global_position.distance_to(t.global_position),0)
			ray.force_raycast_update()

			if (ray.is_colliding()):
				var collider = ray.get_collider()
				if (collider != t):
					targets.erase(t)
					deffered_targets.append(t)
					ray.queue_free()
					continue
			else:
				targets.erase(t)
				ray.queue_free()
				continue
	elif (can_see && has_weapon && is_alerted && !is_dead && !is_unconscious && !is_hostaged && !is_escaping):
		for t in targets.keys():
			if (t.is_in_group("shootable")):
				if (targets[t] == null):
					targets[t] = create_ray()

				var ray = targets[t]

				ray.look_at(t.global_position)
				ray.cast_to = Vector2($AnimatedSprite.global_position.distance_to(t.global_position),0)
				ray.force_raycast_update()

				$AnimatedSprite.look_at(t.global_position)

				if (ray.is_colliding()):
					var collider = ray.get_collider()
					if (t == collider):
						if (can_shoot && !is_shooting && !Game.player_is_dead):
							shoot(t,damage)
				else:
					targets.erase(t)
					deffered_targets.append(t)
					ray.queue_free()
					break
	else:
		targets = {}
		deffered_targets = []

	if (targets.size() == 0):
		is_detecting = false
	else:
		is_detecting = true

	on_physics_process(delta)

func _on_DefferedTimer_timeout():
	if ((can_see || can_detect) && !is_alerted && !is_dead && !is_unconscious && !is_hostaged && !is_escaping):
		for target in deffered_targets:
			if (Game.exceptions.has(target)):
				continue

			var ray = create_ray()

			ray.look_at(target.global_position)
			ray.cast_to = Vector2($AnimatedSprite.global_position.distance_to(target.global_position),0)
			ray.force_raycast_update()

			if (ray.is_colliding()):
				var collider = ray.get_collider()
				if (collider == target && targets.size() < Game.max_targets):
					targets[target] = null
					deffered_targets.erase(target)
					ray.queue_free()
					continue
				else:
					ray.queue_free()
					continue
			else:
				deffered_targets.erase(target)
				ray.queue_free()
				continue

			ray.queue_free()

func _on_Detection_timer_timeout():
	if (is_detecting && can_detect):
		for target in targets.keys():
			for group in target.get_groups():
				if (what_can_see.keys().has(group)):
					var values = what_can_see[group]

					if (group == "Player"):
						if (Game.player_status != Game.player_statuses.NORMAL):
							detection_code = npc_name + values["code"]
							if (Game.player_status == Game.player_statuses.DISGUISED):
								var detection_value_disguised = values["detection_value_disguised"] * ceil((float(Game.difficulty) + 1) / 2)
								if (Game.get_skill("infiltrator",2,2) == "upgraded"):
									detection_value_disguised *= 0.65
									if (detection_value_disguised < 1):
										detection_value_disguised = 1

								detection_value += detection_value_disguised
							else:
								detection_value += values["detection_value_normal"] * (Game.difficulty + 1)
						else:
							continue
					elif (group == "npc"):
						var npc = target.get_parent()
						if (npc.is_dead || npc.is_unconscious):
							detection_code = npc_name + values["code_body"]
							detection_value += values["detection_value_normal"] * (Game.difficulty + 1)
						elif (npc.is_hostaged || npc.is_escaping):
							detection_code = npc_name + values["code_hostage"]
							detection_value += values["detection_value_normal"] * (Game.difficulty + 1)
						elif (npc.is_alerted):
							detection_code = npc_name + values["code_alarm"]
							detection_value += values["detection_value_normal"] * (Game.difficulty + 1)
						else:
							continue
					elif (group == "door"):
						if (target.get_parent().is_broken):
							detection_code = npc_name + "_door"
							detection_value += values["detection_value_normal"] * (Game.difficulty + 1)
						else:
							continue
					elif (group == "glass"):
						if (target.is_broken):
							detection_code = npc_name + "_glass"
							detection_value += values["detection_value_normal"] * (Game.difficulty + 1)
						else:
							continue
					elif (group == "Camera"):
						if (target.get_parent().is_broken):
							detection_code = npc_name + "_camera"
							detection_value += values["detection_value_normal"] * (Game.difficulty + 1)
						else:
							continue
					else:
						detection_code = npc_name + values["code"]
						detection_value += values["detection_value_normal"] * (Game.difficulty + 1)

					if (!$detection.playing):
						$detection.play()

					if (detection_value >= 100):
						show()
						$detection.stop()
						$Detection_timer.stop()
						if (!Game.detection_sound_playing):
							get_tree().create_timer(1).connect("timeout",self,"_on_detection_finished")
							Game.detection_sound_playing = true
							$detected.play()
						return
	else:
		if (detection_value > 0):
			detection_value -= 2

func check_if_seen(node):
	var ray = create_ray()

	ray.look_at(node.global_position)
	ray.cast_to = Vector2($AnimatedSprite.global_position.distance_to(node.global_position),0)
	ray.force_raycast_update()

	if (ray.is_colliding()):
		var collider = ray.get_collider()
		if (collider == node && targets.size() < Game.max_targets):
			targets[node] = null
		else:
			deffered_targets.append(node)
	else:
		ray.queue_free()
		return

	ray.queue_free()

func _on_Detect_area_entered(area):
	if (!is_alerted && can_see && can_detect):
		if (area.is_in_group("detectable")):
			if (Game.exceptions.has(area) || targets.size() >= Game.max_targets):
				deffered_targets.append(area)
			else:
				check_if_seen(area)

func _on_Detect_area_exited(area):
	if (targets.has(area)):
		if (targets[area] != null):
			targets[area].queue_free()

		targets.erase(area)

	if (deffered_targets.has(area)):
		deffered_targets.erase(area)

func _on_Detect_body_entered(body):
	if (!is_alerted && can_see && can_detect):
		if (body.is_in_group("detectable")):
			if (Game.exceptions.has(body) || targets.size() >= Game.max_targets):
				deffered_targets.append(body)
			else:
				check_if_seen(body)
	elif (is_alerted && can_see):
		if (body.is_in_group("shootable") && targets.size() < Game.max_targets):
			targets[body] = null

func _on_Detect_body_exited(body):
	if (targets.has(body)):
		if (targets[body] != null):
			targets[body].queue_free()

		targets.erase(body)

	if (deffered_targets.has(body)):
		deffered_targets.erase(body)

func add_exception(object):
	for ray in targets.values():
		if (is_instance_valid(object) && is_instance_valid(ray)):
			ray.add_exception(object)

func remove_exception(object):
	for ray in targets.values():
		if (is_instance_valid(object) && is_instance_valid(ray)):
			ray.remove_exception(object)

func _process(delta):
	if (!Game.game_process):
		return

	if (detection_value > 0 && detection_value < 100 && !is_dead && !is_unconscious && !is_hostaged && !is_escaping && can_detect):
		show()
		$Marker.show()
		$Marker/AnimatedSprite.animation = "question"
		$Detection_bar.show()
		$Detection_bar.value = detection_value
	elif (detection_value >= 100 && !is_dead && !is_unconscious && !is_hostaged && !is_escaping && can_detect):
		show()
		$Marker.show()
		$Marker/AnimatedSprite.animation = "alert"
		$Detection_bar.hide()
		if ($Alert_timer.time_left <= 0):
			alerted()
			$Detection_timer.stop()
			$MoveTimer.stop()
			is_moving = false

			is_alerted = true
			if (!Game.is_ecm_on):
				$Alert_timer.start()
			else:
				deffer_call()
	else:
		$Marker.hide()
		$Detection_bar.hide()

	set_npc_interactions()

	check_interactions()

	on_process(delta)

func on_process(delta: float):
	pass

func _on_Hitbox_area_entered(area: Area2D):
	if (area.is_in_group("plr_bullets")):
		take_damage(area.damage,area.type)
	elif (area.is_in_group("melee")):
		knockout()

func take_damage(damage: float,type: String = "none"):
	health -= damage
	if (health <= 0):
		kill(damage,type)
		return

	$AnimatedSprite.modulate = Color.red

	yield(get_tree().create_timer(0.1),"timeout")

	$AnimatedSprite.modulate = Color.white


func shoot(target, damage):
	is_shooting = true

	if (target != null):
		$AnimatedSprite.look_at(target.global_position)

		var bullet = Game.scene_objects["enm_bullet"].instance()
		bullet.accuracy = 100
		bullet.target = target
		bullet.global_position = $AnimatedSprite/BulletOrigin.global_position
		bullet.damage = damage

		Game.game_scene.add_child(bullet)

		var noise = Game.scene_objects["alert"].instance()

		noise.radius = 4000
		noise.time = 0.1
		noise.global_position = $AnimatedSprite.global_position

		Game.game_scene.call_deferred("add_child",noise)

		noise.start()

		$shoot.play()

	$Shoot_timer.start()

func alerted():
	if (is_dead || is_unconscious):
		can_interact = false
		$Interaction_panel/VBoxContainer/Action3.text = ""

	if (npc_name == "guard"):
		$AnimatedSprite.animation = "shoot"

	Game.remove_exception($Interaction_hitbox)

func kill(damage: float = 0,type: String = "none"):
	if (!is_dead):
		if (is_tied_hostage):
			Game.hostages -= 1

			if (Game.get_skill("mastermind",4,2) != "none"):
				if (Game.hostages == 0):
					Game.game_scene.get_node("Timers/HostageTaker").stop()
					Game.player_max_stamina -= 25
					Game.player.stamina -= 25

			if (Game.get_skill("mastermind",3,2) == "upgraded"):
				Game.player_damage_reduction -= 1.5

				if (Game.player_damage_reduction < 0):
					Game.player_damage_reduction = 0


		if (Game.get_skill("engineer",4,3) != "none" && !Game.push_it_cooldown && npc_name == "cop"):
			Game.player.push_it()

		if (Game.get_skill("infiltrator",4,3) != "none" && Game.is_ecm_on):
			Game.player.health += (Game.player_max_health * 0.035)
			if (Game.player.health > Game.player_max_health):
				Game.player.health = Game.player_max_health

		if (npc_name == "cop" || npc_name == "guard"):
			var ammo_box_instance = Game.scene_objects["ammo"].instance()
			ammo_box_instance.global_position = global_position
			Game.game_scene.call_deferred("add_child",ammo_box_instance)

			if (Game.get_skill("commando",1,1) == "upgraded"):
				Game.donor_kill_counter += 1
				if (Game.donor_kill_counter >= 10):
					Game.donor_kill_counter = 0

					var ammo_box_instance2 = Game.scene_objects["ammo"].instance()
					ammo_box_instance.global_position = Vector2(global_position.x - 75, global_position.y)
					ammo_box_instance2.global_position = Vector2(global_position.x + 75, global_position.y)
					Game.game_scene.call_deferred("add_child",ammo_box_instance2)

		if (!Game.is_game_loud):
			can_interact = true
		else:
			$Interaction_panel/VBoxContainer/Action3.text = ""

		emit_signal("npc_dead",self)
		is_dead = true

		has_disguise = false

		is_following = false
		is_escaping = false
		is_moving = false

		is_alerted = false
		is_unconscious = false
		is_hostaged = false
		is_tied_hostage = false

		$Alert_timer.stop()
		$Shoot_timer.stop()
		$MoveTimer.stop()
		$Escape_timer.stop()
		$DefferedTimer.stop()

		$detection.stop()
		$detected.stop()

		Game.remove_exception($Interaction_hitbox)

		$AnimatedSprite/Hitbox/CollisionShape2D.set_deferred("disabled",true)

		if (Game.is_game_loud):
			if (Savedata.player_settings["dead_bodies"]):
				$Dissappear.start()
			else:
				_on_Dissappear_timeout()

		if (has_penalty):
			Game.killed_civilians_penalty += 2500 * (Game.difficulty + 1)
			var lines = [
				"BAIN: Hey! Don't kill civilians! That costs us money!",
				"BAIN: What are you doing? This will cost us money!",
				"BAIN: Stop killing civilians! We have to pay for it now!",
				"BAIN: Do not kill civilians man! We're losing money!",
				"BAIN: Look, you can knock out people, but do not kill civilians!",
			]

			Game.ui.update_subtitle(lines[randi() % lines.size()],1,5)


func knockout():
	if (!is_unconscious && !is_dead && npc_name != "cop" && can_knock):
		is_unconscious = true
		if (is_tied_hostage):
			if (Game.get_skill("mastermind",4,2) != "none"):
				Game.game_scene.get_node("Timers/HostageTaker").stop()
				Game.player_max_stamina -= 25
				Game.player.stamina -= 25

			if (Game.get_skill("mastermind",3,2) == "upgraded"):
				Game.player_damage_reduction -= 1.5

				if (Game.player_damage_reduction < 0):
					Game.player_damage_reduction = 0

			Game.hostages -= 1

		if (!Game.is_game_loud):
			can_interact = true
		else:
			$Interaction_panel/VBoxContainer/Action3.text = ""

		is_following = false
		is_escaping = false
		is_moving = false

		is_dead = false
		is_alerted = false
		is_hostaged = false
		is_tied_hostage = false

		$Alert_timer.stop()
		$Shoot_timer.stop()
		$MoveTimer.stop()
		$Escape_timer.stop()
		$DefferedTimer.stop()

		$detection.stop()
		$detected.stop()

		$knockout.play()

		$AnimatedSprite/Hitbox/CollisionShape2D.set_deferred("disabled",true)

		emit_signal("npc_knocked",self)

		Game.remove_exception($Interaction_hitbox)

func hostage():
	if (Game.get_skill("mastermind",3,2) != "none"):
		$Escape_timer.wait_time = 15
	else:
		$Escape_timer.wait_time = 5

	if (npc_name != "cop"):
		can_interact = true

		is_following = false
		is_escaping = false
		is_moving = false

		is_hostaged = true

		$MoveTimer.stop()
		$Escape_timer.start()
		$Alert_timer.stop()
		$DefferedTimer.stop()

		$detection.stop()

		if (!is_alerted):
			if (!Game.detection_sound_playing):
				Game.detection_sound_playing = true
				get_tree().create_timer(1).connect("timeout",self,"_on_detection_finished")

				$detected.play()

		emit_signal("npc_hostaged",self)

		Game.remove_exception($Interaction_hitbox)

func tie():
	if (Game.handcuffs > 0):
		if (Game.get_skill("mastermind",4,2) != "none"):
			var timer = Game.game_scene.get_node("Timers/HostageTaker")
			timer.start()
			Game.player_max_stamina += 25
			Game.player.stamina += 25

			if (!timer.is_connected("timeout",Game.player,"hostage_taker")):
				timer.connect("timeout",Game.player,"hostage_taker")

		if (Game.get_skill("mastermind",3,2) == "upgraded"):
			if (Game.player_damage_reduction < 15):
				Game.player_damage_reduction += 1.5

		Game.handcuffs -= 1
		Game.hostages += 1

		is_tied_hostage = true

		$Escape_timer.stop()
	else:
		Game.ui.update_popup("You have no handcuffs!",2)

func interrogate():
	was_interrogated = true

func _on_Alert_timer_timeout():
	if (!Game.is_ecm_on && !is_dead && !is_unconscious && !is_hostaged):
		alarm_on()
		emit_signal("alerted",detection_code)
	else:
		if (!is_dead && !is_unconscious && !is_hostaged):
			deffer_call()

func alarm_on():
	if (is_dead || is_unconscious):
		can_interact = false
		$Interaction_panel/VBoxContainer/Action3.text = ""

	for target in targets.keys():
		targets[target].queue_free()
		targets.erase(target)

	if (!has_weapon):
		deffered_targets = []

	is_alerted = true

	$Alert_timer.stop()

	detection_value = 0
	$Detection_timer.stop()
	$MoveTimer.stop()
	is_moving = false

	if (is_dead):
		if (Savedata.player_settings["dead_bodies"]):
			$Dissappear.start()
		else:
			_on_Dissappear_timeout()

func _on_Shoot_timer_timeout():
	is_shooting = false

func noise_heard():
	if (!Game.detection_sound_playing):
		get_tree().create_timer(1).connect("timeout",self,"_on_detection_finished")
		Game.detection_sound_playing = true
		$detected.play()

	detection_value = 100
	$Detection_timer.stop()

	$Marker.show()
	$Marker/AnimatedSprite.animation = "alert"
	$Detection_bar.hide()
	if ($Alert_timer.time_left <= 0):
		$MoveTimer.stop()
		is_moving = false

		is_alerted = true
		if (!Game.is_ecm_on):
			$Alert_timer.start()
		else:
			deffer_call()

	detection_code = npc_name + "_noise"

func _on_MoveTimer_timeout():
	on_move()

func on_move():
	pass

func _on_Escape_timer_timeout():
	on_escape()

func on_escape():
	if (!can_escape):
		return

func retry_escape():
	if (!can_escape):
		return

func try_escape():
	if (!can_escape):
		return

func deffer_call():
	yield(get_tree().create_timer(1),"timeout")

	if (Game.is_ecm_on && !is_dead && !is_unconscious && !is_hostaged):
		deffer_call()
	else:
		if (!is_dead && !is_unconscious && !is_hostaged):
			$Alert_timer.start()

func _on_VisibilityNotifier2D_screen_entered():
	show()

func _on_VisibilityNotifier2D_screen_exited():
	if (!is_dead && !is_unconscious && !is_hostaged && !is_escaping && !is_alerted && !is_detecting):
		hide()


func _on_Dissappear_timeout():
	Game.remove_exception($Interaction_hitbox)

	queue_free()

func _on_detection_finished():
	Game.detection_sound_playing = false
