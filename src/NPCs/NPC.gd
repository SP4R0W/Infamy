extends Node2D
class_name NPC

signal object_interaction_started(object)
signal object_interaction_aborted(object)
signal object_interaction_finished(object)

signal npc_hostaged(object, data)
signal npc_interrogated(object,data)
signal npc_dead(object)

signal alerted(code)

export var can_interact: bool = true
export var can_see: bool = true

export var info: String = "none"

export var is_dead: bool = false
export var is_unconscious: bool = false
export var is_hostaged: bool = false
export var is_tied_hostage: bool = false
export var is_alerted: bool = false

onready var rays: Node2D = $AnimatedSprite/Raycasts

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

func _ready():
	connect("alerted",Game,"turn_game_loud")
	
	$Marker.hide()
	$Detection_bar.hide()
	$Interaction_panel.hide()
	$Interaction_panel/VBoxContainer/Interaction_progress.hide()

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
		
func _physics_process(delta):
	if (!Game.game_process):
		return

	if (can_see && !is_hostaged && !is_unconscious && !is_dead):
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
	else:
		targets = []
		raycasts = []
		
		for x in range(rays.get_child_count()):
			var ray: RayCast2D = rays.get_child(x)
			ray.queue_free()
		
	on_physics_process()
		
func on_physics_process():
	pass
		
func _process(delta):
	if (!Game.game_process):
		return

	if (detection_value > 0 && detection_value < 100):
		$Marker.show()
		$Marker/AnimatedSprite.animation = "question"
		$Detection_bar.show()
		$Detection_bar.value = detection_value
	elif (detection_value >= 100):
		$Marker.show()
		$Marker/AnimatedSprite.animation = "alert"
		$Detection_bar.hide()
		if ($Alert_timer.time_left <= 0):
			is_alerted = true
			$Alert_timer.start()
	else:
		$Marker.hide()
		$Detection_bar.hide()
	
	check_interactions()
		
	on_process()
		
func check_interactions():
	pass
	
func finish_interactions():
	pass
		
func on_process():
	pass
		
func _on_Detection_timer_timeout():
	if (is_detecting):
		for ray in raycasts:
			if (ray["detecting"]):
				var object = ray["object"]
				if (object.is_in_group("Player")):
					if (Game.player_status != Game.player_statuses.NORMAL):
						detection_code = "npc_player"
						if (Game.player_status == Game.player_statuses.DISGUISED):
							detection_value += 2							
						else:
							detection_value += 5
				elif (object.is_in_group("npc")):
					pass
				elif (object.is_in_group("Camera")):
					pass
				elif (object.is_in_group("glass")):
					if (object.is_broken):
						detection_code = "npc_glass"
						detection_value += 10
				elif (object.is_in_group("bags")):
					detection_code = "npc_bag"
					detection_value += 10
				elif (object.is_in_group("drill")):
					detection_code = "npc_drill"
					detection_value += 10
					
			if (detection_value >= 100):
				break
	else:
		detection_value -= 2

func _on_Hitbox_area_entered():
	#kill NPC
	pass # Replace with function body.

func _on_Detect_area_entered(area):
	if (area.is_in_group("detectable") && area != $Interaction_hitbox):
		if (!targets.has(area)):
			targets.append(area)
				
func _on_Detect_area_exited(area):
	if (area.is_in_group("detectable") && area != $Interaction_hitbox):
		if (!targets.has(area)):
			targets.append(area)

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
	can_see = false
	
	targets = []
	
	$Alert_timer.stop()
	
	detection_value = 0
	$Detection_timer.stop()
