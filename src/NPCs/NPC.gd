extends Node2D
class_name NPC

var bullet_scene = preload("res://src/Weapons/Enemy_bullet.tscn")

signal object_interaction_started(object)
signal object_interaction_aborted(object)
signal object_interaction_finished(object)

signal npc_hostaged(object, data)
signal npc_interrogated(object,data)
signal npc_dead(object)

signal alerted(code)

export var health: float = 10

export var can_interact: bool = false
export var can_see: bool = true
export var has_weapon: bool = false

export var info: String = "none"

export var is_dead: bool = false
export var is_unconscious: bool = false
export var is_hostaged: bool = false
export var is_tied_hostage: bool = false
export var is_alerted: bool = false
export var has_disguise: bool = true

onready var move_timer: Timer = $MoveTimer
onready var rays: Node2D = $AnimatedSprite/Raycasts
onready var npc_name: String = name.to_lower()

var action: String = "loop"

var has_focus: bool = false

var raycasts = []
var targets = []

var exceptions = []

var base_detection_speed = 0.1

var detection_code: String = "None"
var detection_value: int = 0

var is_detecting: bool = false
var is_detecting_player_disguise: bool = false

var is_shooting: bool = false
var can_shoot: bool = false

var was_interrogated: bool = false

var is_following: bool = false
var is_escaping: bool = false
var is_moving: bool = false

func _ready():	
	connect("alerted",Game,"turn_game_loud")
	
	$Marker.hide()
	$Detection_bar.hide()
	$Interaction_panel.hide()
	$Interaction_panel/VBoxContainer/Interaction_progress.hide()
	
	on_ready()
	
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
	ray.cast_to = Vector2(3500,0)
	ray.collide_with_areas = true
	ray.collide_with_bodies = true	
	ray.enabled = false
	ray.exclude_parent = true
	ray.set_collision_mask_bit(0,true)
	ray.set_collision_mask_bit(3,true)
	ray.set_collision_mask_bit(12,true)
	ray.set_collision_mask_bit(15,true)
	
	ray.add_exception($Interaction_hitbox)
	for exception in exceptions:
		ray.add_exception(exception)
	
	rays.add_child(ray)
	var dict = {"ray_cast":ray,"detecting":false,"object":null}
	raycasts.append(dict)
	
	return dict
	
func add_exception(object):
	exceptions.append(object)
	
	for x in range(rays.get_child_count()):
		var ray: RayCast2D = rays.get_child(x)
		ray.add_exception(object)
		
func remove_exception(object):
	exceptions.erase(object)
	
	for x in range(rays.get_child_count()):
		var ray: RayCast2D = rays.get_child(x)
		ray.remove_exception(object)
		
func set_npc_interactions():
	pass
				
func check_interactions():
	pass
	
func finish_interactions():
	pass
	
func _physics_process(delta):
	if (!Game.game_process):
		return

	if (can_see && !is_hostaged && !is_unconscious && !is_dead && !is_alerted && !is_escaping):
		for x in range (targets.size()):
			if (x < targets.size()):
				if (targets.has(targets[x])):
					var target = targets[x]
					var ray_dict = {}

					if (rays.get_child_count() < targets.size() || rays.get_child_count() == 0):
						ray_dict = create_ray()
					else:
						ray_dict = raycasts[x]
						
					if (!get_tree().get_nodes_in_group("detectable").has(target)):
						targets.erase(target)
						ray_dict["detecting"] = false
						ray_dict["object"] = null
						continue
					
					var ray = ray_dict["ray_cast"]
					ray.enabled = true
						
					ray.look_at(target.global_position)
					if (ray.is_colliding() && ray.get_collider() == target):
						ray_dict["detecting"] = true
						ray_dict["object"] = target
					else:
						ray_dict["detecting"] = false
						ray_dict["object"] = null
					
		if (targets.size() == 0):
			for x in range(rays.get_child_count()):
				var ray: RayCast2D = rays.get_child(x)
				raycasts[x]["detecting"] = false
				ray.enabled = false
		elif (rays.get_child_count() > targets.size()):
			for x in range(rays.get_child_count() - 1,targets.size(),-1):
				var ray: RayCast2D = rays.get_child(x)
				raycasts[x]["detecting"] = false
				ray.enabled = false
		
		var values = []
		for ray in raycasts:
			values.append(ray["detecting"])
			
		if (values.has(true)):
			is_detecting = true
		else:
			is_detecting = false
		
		if (is_detecting):
			if ($Detection_timer.time_left <= 0 && detection_value <= 100):
				$Detection_timer.wait_time = base_detection_speed
				$Detection_timer.start()
		else:
			if ($Detection_timer.time_left <= 0 && detection_value > 0 && detection_value < 100):
				$Detection_timer.wait_time = base_detection_speed
				$Detection_timer.start()
	elif (can_see && is_alerted && has_weapon && !is_hostaged && !is_unconscious && !is_dead && !is_escaping):
		for x in range (targets.size()):
			if (x < targets.size()):
				if (targets.has(targets[x])):
					var target = targets[x]
					var ray_dict = {}

					if (rays.get_child_count() < targets.size() || rays.get_child_count() == 0):
						ray_dict = create_ray()
					else:
						ray_dict = raycasts[x]
						
					if (!get_tree().get_nodes_in_group("shootable").has(target)):
						targets.erase(target)
						ray_dict["detecting"] = false
						ray_dict["object"] = null
						continue
					
					var ray = ray_dict["ray_cast"]
					ray.enabled = true
						
					ray.look_at(target.global_position)
					if (ray.is_colliding() && ray.get_collider() == target):
						ray_dict["detecting"] = true
						ray_dict["object"] = target
					else:
						ray_dict["detecting"] = false
						ray_dict["object"] = null
					
		if (targets.size() == 0):
			for x in range(rays.get_child_count()):
				var ray: RayCast2D = rays.get_child(x)
				raycasts[x]["detecting"] = false
				ray.enabled = false
		elif (rays.get_child_count() > targets.size()):
			for x in range(rays.get_child_count() - 1,targets.size(),-1):
				var ray: RayCast2D = rays.get_child(x)
				raycasts[x]["detecting"] = false
				ray.enabled = false
		
		var values = []
		for ray in raycasts:
			values.append(ray["detecting"])
			
		if (values.has(true)):
			can_shoot = true
		else:
			can_shoot = false
			
		if (can_shoot && !is_shooting):
			shoot()
			
	else:
		targets = []
		raycasts = []
		
		is_detecting = false
		can_shoot = false
		
		for x in range(rays.get_child_count()):
			var ray: RayCast2D = rays.get_child(x)
			ray.queue_free()
		
	on_physics_process(delta)
		
func on_physics_process(delta: float):
	pass
		
func _process(delta):
	if (!Game.game_process):
		return

	if (detection_value > 0 && detection_value < 100 && !is_dead && !is_unconscious && !is_hostaged && !is_escaping):
		$Marker.show()
		$Marker/AnimatedSprite.animation = "question"
		$Detection_bar.show()
		$Detection_bar.value = detection_value
	elif (detection_value >= 100 && !is_dead && !is_unconscious && !is_hostaged && !is_escaping):
		$Marker.show()
		$Marker/AnimatedSprite.animation = "alert"
		$Detection_bar.hide()
		if ($Alert_timer.time_left <= 0):
			is_alerted = true
			$Alert_timer.start()
	else:
		$Marker.hide()
		$Detection_bar.hide()
	
	set_npc_interactions()
	
	check_interactions()
		
	on_process(delta)
		
func on_process(delta: float):
	pass
		
func _on_Detection_timer_timeout():
	if (is_detecting):
		for ray in raycasts:
			if (ray["detecting"]):
				var object = ray["object"]
				if (object.is_in_group("Player")):
					if (Game.player_status != Game.player_statuses.NORMAL):
						detection_code = npc_name + "_player"
						if (Game.player_status == Game.player_statuses.DISGUISED):
							detection_value += 2							
						else:
							detection_value += 5
				elif (object.is_in_group("npc")):
					var npc = object.get_parent()
					if (npc.is_dead || npc.is_unconscious):
						detection_code = npc_name + "_body"
						detection_value += 10				
					elif (npc.is_hostaged || npc.is_escaping):
						detection_code = npc_name + "_hostage"
						detection_value += 10
					elif (npc.is_alerted):
						detection_code = npc_name + "_alert"
						detection_value += 10															
				elif (object.is_in_group("Camera")):
					var camera = object.get_parent()
					if (camera.is_broken):
						detection_code = npc_name + "_camera"
						detection_value += 10
				elif (object.is_in_group("glass")):
					if (object.is_broken):
						detection_code = npc_name + "_glass"
						detection_value += 10
				elif (object.is_in_group("bags")):
					detection_code = npc_name + "_bag"
					detection_value += 10
				elif (object.is_in_group("drill")):
					if (object.get_parent().visible):
						detection_code = npc_name + "_drill"
						detection_value += 10
					
			if (detection_value >= 100):
				break
	else:
		detection_value -= 2

func _on_Hitbox_area_entered(area: Area2D):
	if (area.is_in_group("plr_bullets")):
		health -= area.damage
		if (health < 1):
			kill()
	elif (area.is_in_group("melee")):
		knockout()
		
func shoot():
	is_shooting = true
	var target = null
	
	for ray in raycasts:
		if (ray["detecting"]):
			target = ray["object"]
	
	var bullet = bullet_scene.instance()
	bullet.accuracy = 100
	Game.game_scene.add_child(bullet)
	bullet.target = target
	bullet.global_position = $AnimatedSprite/BulletOrigin.global_position

	$Shoot_timer.start()
		
func kill():
	can_interact = true
	has_disguise = false
	
	is_following = false
	is_escaping = false
	is_moving = false
	
	is_dead = true
	is_alerted = false
	is_unconscious = false
	is_hostaged = false
	is_tied_hostage = false
	
	$Alert_timer.stop()
	$Shoot_timer.stop()
	$MoveTimer.stop()
	$Escape_timer.stop()	
	
func knockout():
	can_interact = true
	
	is_following = false
	is_escaping = false
	is_moving = false
	
	is_dead = false
	is_alerted = false
	is_unconscious = true
	is_hostaged = false
	is_tied_hostage = false
	
	$Alert_timer.stop()
	$Shoot_timer.stop()
	$MoveTimer.stop()
	$Escape_timer.stop()	
	
func hostage():
	can_interact = true
	
	is_following = false
	is_escaping = false
	is_moving = false
	
	is_hostaged = true
	
	$MoveTimer.stop()
	$Escape_timer.start()

func tie():
	is_tied_hostage = true
	
	$Escape_timer.stop()
	
func interrogate():
	was_interrogated = true

func _on_Detect_area_entered(area):
	if (!is_alerted):
		if (area.is_in_group("detectable") && area != $Interaction_hitbox):
			if (!targets.has(area)):
				targets.append(area)
	else:
		if (area.is_in_group("shootable")):
			if (!targets.has(area)):
				targets.append(area)		
				
func _on_Detect_area_exited(area):
	if (targets.has(area)):
		targets.erase(area)

func _on_Detect_body_entered(body):
	if (!targets.has(body)):
		targets.append(body)

func _on_Detect_body_exited(body):
	if (targets.has(body)):
		targets.erase(body)
		
func _on_Alert_timer_timeout():
	alarm_on()
	emit_signal("alerted",detection_code)

func alarm_on():
	is_alerted = true

	$Alert_timer.stop()
	
	detection_value = 0
	$Detection_timer.stop()


func _on_Shoot_timer_timeout():
	is_shooting = false

func noise_heard():
	detection_value = 100
	
	$Marker.show()
	$Marker/AnimatedSprite.animation = "alert"
	$Detection_bar.hide()
	if ($Alert_timer.time_left <= 0):
		is_alerted = true
		$Alert_timer.start()
		
	detection_code = "guard_noise"

func _on_MoveTimer_timeout():
	on_move()
	
func on_move():
	pass

func _on_Escape_timer_timeout():
	on_escape()
	
func on_escape():
	pass

func retry_escape():
	pass
	
func try_escape():
	pass
