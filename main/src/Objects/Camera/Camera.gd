extends Node2D

signal object_interaction_started(object)
signal object_interaction_aborted(object)
signal object_interaction_finished(object)

signal alerted(code)

export(String, "armor","default") var camera_type = "default"
export var disguises_needed = []

export var can_interact: bool = true
export var is_disabled: bool = true
export var is_broken: bool = false

export var what_can_see: Dictionary = {
	"Player":{
		"detection_value_normal":4,
		"detection_value_disguised":1.5,
		"code": "camera_player"
	},
	"npc":{
		"detection_value_normal":5,
		"code_body": "camera_body",
		"code_alarm": "camera_alert",
		"code_hostage": "camera_hostage"
	},
	"bags":{
		"detection_value_normal":5,
		"code": "camera_bag"
	},
	"door":{
		"detection_value_normal":5,
		"code": "camera_door"
	},
	"glass":{
		"detection_value_normal":5,
		"code": "camera_glass"
	},
	"drill":{
		"detection_value_normal":5,
		"code": "camera_drill"
	}
}

onready var rays: Node2D = $AnimatedSprite/Raycasts

var action: String = "loop"

var has_focus: bool = false

var deffered_targets = []
var targets = {}

var detection_code: String = "None"
var detection_value: int = 0

var is_detecting: bool = false

var is_alerted: bool = false

var fov_polygons: Array = [
	PoolVector2Array([Vector2(80,-24),Vector2(1000,-900),Vector2(1000,900),Vector2(80,24)]),
	PoolVector2Array([Vector2(80,-24),Vector2(1200,-900),Vector2(1200,900),Vector2(80,24)]),
	PoolVector2Array([Vector2(80,-24),Vector2(1450,-1150),Vector2(1450,1150),Vector2(80,24)]),
	PoolVector2Array([Vector2(80,-24),Vector2(1650,-1150),Vector2(1650,1150),Vector2(80,24)]),
]

func _ready():
	draw_fov()
	connect("alerted",Game,"turn_game_loud")

	$Marker.hide()
	$Detection_bar.hide()
	$Interaction_panel.hide()
	$Interaction_panel/VBoxContainer/Interaction_progress.hide()
	$AnimatedSprite/Hitbox/CollisionShape2D.disabled = true

	Game.add_exception($Interaction_hitbox)

	if (Game.difficulty > 2):
		camera_type = "armor"
	else:
		camera_type = "default"

func activate_camera():
	is_disabled = false
	can_interact = true

	$AnimatedSprite/Hitbox/CollisionShape2D.disabled = false

func draw_fov():
	if (Game.difficulty != 4):
		$AnimatedSprite/Detect/CollisionPolygon2D.polygon = fov_polygons[Game.difficulty]
	else:
		$AnimatedSprite/Detect/CollisionPolygon2D.polygon = fov_polygons[3]

func show_panel():
	has_focus = true
	$Interaction_panel.show()
	$Interaction_panel/VBoxContainer/Interaction_progress.hide()

func hide_panel():
	has_focus = false
	$Interaction_panel.hide()

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

func add_exception(object):
	for ray in targets.values():
		if (is_instance_valid(object) && is_instance_valid(ray)):
			ray.add_exception(object)

func remove_exception(object):
	for ray in targets.values():
		if (is_instance_valid(object) && is_instance_valid(ray)):
			ray.remove_exception(object)

func _physics_process(delta):
	if (!Game.game_process):
		return

	if (!is_alerted && !is_disabled && !is_broken):
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
	else:
		targets = {}
		deffered_targets = []

	if (targets.size() == 0):
		is_detecting = false
	else:
		is_detecting = true

func _process(delta):
	if (!Game.game_process):
		return

	if (is_broken):
		$AnimatedSprite.animation = (camera_type + "_broken")
	elif (is_disabled):
		$AnimatedSprite.animation = (camera_type + "_off")
	else:
		$AnimatedSprite.animation = (camera_type + "_on")

	$AnimatedSprite.play()

	if (detection_value > 0 && detection_value < 100):
		$Marker.show()
		$Marker/AnimatedSprite.animation = "question"
		$Detection_bar.show()
		$Detection_bar.value = detection_value
	elif (detection_value >= 100):
		if (Game.difficulty <= 3):
			can_interact = false
			$Marker.show()
			$Marker/AnimatedSprite.animation = "alert"
			$Detection_bar.hide()
			if ($Alert_timer.time_left <= 0):
				is_alerted = true
				if (!Game.is_ecm_on):
					$Alert_timer.start()
				else:
					deffer_call()
		else:
			for target in targets.keys():
				targets[target].queue_free()
				targets.erase(target)

			deffered_targets = []

			Game.map.on_Camera_alerted()
	else:
		$Marker.hide()
		$Detection_bar.hide()

	if (has_focus && can_interact && !is_disabled && !is_broken && Game.get_skill("infiltrator",3,1) != "none"):
		if (Input.is_action_pressed("interact1") && Game.player_can_interact):
			if (!Game.player_is_interacting):
				Game.suspicious_interaction = true
				Game.player_is_interacting = true

				emit_signal("object_interaction_started",self,self.action)

				$Interaction_timer.wait_time = 3
				$Interaction_timer.start()

				$Interaction_panel/VBoxContainer/Interaction_progress.show()
		else:
			if (Game.player_is_interacting):
				Game.suspicious_interaction = false
				emit_signal("object_interaction_aborted",self,self.action)

				Game.player_is_interacting = false
				$Interaction_timer.stop()

				$Interaction_panel/VBoxContainer/Interaction_progress.hide()
	else:
		hide_panel()

	if (Game.player_is_interacting && has_focus):
		$Interaction_panel/VBoxContainer/Interaction_progress.value = (($Interaction_timer.wait_time - $Interaction_timer.time_left) / $Interaction_timer.wait_time) * 100

func _on_Hitbox_area_entered(area):
	if (area.is_in_group("plr_bullets")):
		if (camera_type == "default"):
			$Loop_timer.stop()
			$AnimatedSprite.animation = "default_broken"
			can_interact = false
			is_broken = true
			detection_value = 0
			$Detection_timer.stop()
			$Alert_timer.stop()

			Game.remove_exception($Interaction_hitbox)

func _on_Interaction_timer_timeout():
	if (Game.player_is_interacting):
		Game.player_is_interacting = false
		$Interaction_panel/VBoxContainer/Interaction_progress.hide()

		Game.player_can_interact = false
		Game.suspicious_interaction = false
		get_tree().create_timer(0.2).connect("timeout",Game,"stop_interaction_grace")

		emit_signal("object_interaction_finished",self,self.action)

		can_interact = false
		is_disabled = true

		if (Game.get_skill("infiltrator",3,1) == "basic"):
			$Loop_timer.wait_time = 10
		else:
			$Loop_timer.wait_time = 25

		$Loop_timer.start()

func _on_Deffered_timer_timeout():
	if (!is_alerted && !is_disabled && !is_broken):
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
	if (!is_alerted && !is_disabled && !is_broken):
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
	if (!is_alerted && !is_disabled && !is_broken):
		if (body.is_in_group("detectable")):
			if (Game.exceptions.has(body) || targets.size() >= Game.max_targets):
				deffered_targets.append(body)
			else:
				check_if_seen(body)

func _on_Detect_body_exited(body):
	if (targets.has(body)):
		if (targets[body] != null):
			targets[body].queue_free()

		targets.erase(body)

	if (deffered_targets.has(body)):
		deffered_targets.erase(body)


func _on_Loop_timer_timeout():
	can_interact = true
	is_disabled = false

func _on_Detection_timer_timeout():
	if (is_detecting):
		for target in targets.keys():
			for group in target.get_groups():
				if (what_can_see.keys().has(group)):
					var values = what_can_see[group]

					if (group == "Player"):
						if (Game.player_status != Game.player_statuses.NORMAL):
							detection_code = values["code"]
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
							detection_code = values["code_body"]
							detection_value += values["detection_value_normal"] * (Game.difficulty + 1)
						elif (npc.is_hostaged || npc.is_escaping):
							detection_code = values["code_hostage"]
							detection_value += values["detection_value_normal"] * (Game.difficulty + 1)
						elif (npc.is_alerted):
							detection_code = values["code_alarm"]
							detection_value += values["detection_value_normal"] * (Game.difficulty + 1)
						else:
							continue
					elif (group == "door"):
						if (target.get_parent().is_broken):
							detection_value += values["detection_value_normal"] * (Game.difficulty + 1)
						else:
							continue
					elif (group == "glass"):
						if (target.is_broken):
							detection_value += values["detection_value_normal"] * (Game.difficulty + 1)
						else:
							continue
					else:
						detection_code = values["code"]
						detection_value += values["detection_value_normal"] * (Game.difficulty + 1)

					if (!$detection.playing):
						$detection.play()

					if (detection_value >= 100):
						$detection.stop()
						Game.game_scene.get_node("detected").play()
						$Detection_timer.stop()
						return
	else:
		if (detection_value > 0):
			detection_value -= 2

func _on_Alert_timer_timeout():
	if (!Game.is_ecm_on):
		alarm_on()
		emit_signal("alerted",detection_code)
	else:
		deffer_call()

func alarm_on():
	for target in targets.keys():
		targets[target].queue_free()
		targets.erase(target)

	deffered_targets = []

	can_interact = false
	$Loop_timer.stop()

	is_alerted = true
	if (!is_broken):
		is_disabled = true

	$Alert_timer.stop()

	detection_value = 0
	$Detection_timer.stop()

func deffer_call():
	yield(get_tree().create_timer(1),"timeout")

	if (Game.is_ecm_on):
		deffer_call()
	else:
		$Alert_timer.start()
