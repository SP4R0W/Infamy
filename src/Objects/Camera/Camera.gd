extends Node2D

signal object_interaction_started(object)
signal object_interaction_aborted(object)
signal object_interaction_finished(object)

signal alerted(code)

export(String, "armor","default") var camera_type = "default"
export var disguises_needed = []

export var can_interact: bool = true
export var is_disabled: bool = false
export var is_broken: bool = false

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

var is_alerted: bool = false

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
	
func create_ray() -> RayCast2D:
	var ray = RayCast2D.new()
	ray.cast_to = Vector2(3000,0)
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
	
func _physics_process(delta):
	if (!Game.game_process):
		return
	
	if (!is_disabled && !is_broken && !is_alerted):
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
		$Marker.show()
		$Marker/AnimatedSprite.animation = "alert"
		$Detection_bar.hide()
		if ($Alert_timer.time_left <= 0):
			is_alerted = true
			$Alert_timer.start()
	else:
		$Marker.hide()
		$Detection_bar.hide()
	
	if (has_focus && can_interact && !is_disabled && !is_broken):
		if (Input.is_action_pressed("interact1") && Game.player_can_interact):
			if (!Game.player_is_interacting):
				Game.player_is_interacting = true
				
				emit_signal("object_interaction_started",self.name,self.action)
				
				$Interaction_timer.wait_time = 3
				$Interaction_timer.start()
				
				$Interaction_panel/VBoxContainer/Interaction_progress.show()
		else:
			if (Game.player_is_interacting):
				emit_signal("object_interaction_aborted",self.name,self.action)
				
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

func _on_Interaction_timer_timeout():
	if (Game.player_is_interacting):
		Game.player_is_interacting = false
		$Interaction_panel/VBoxContainer/Interaction_progress.hide()
		
		Game.player_can_interact = false
		get_tree().create_timer(0.2).connect("timeout",Game,"stop_interaction_grace")
		
		emit_signal("object_interaction_finished",self.name,self.action)
		
		can_interact = false
		is_disabled = true
		$Loop_timer.start()
		
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

func _on_Loop_timer_timeout():
	can_interact = true
	is_disabled = false

func _on_Detection_timer_timeout():
	if (is_detecting):
		for ray in raycasts:
			if (ray["detecting"]):
				var object = ray["object"]
				if (object.is_in_group("Player")):
					if (Game.player_status != Game.player_statuses.NORMAL):
						detection_code = "camera_player"
						if (Game.player_status == Game.player_statuses.DISGUISED):
							detection_value += 2							
						else:
							detection_value += 5
				elif (object.is_in_group("npc")):
					var npc = object.get_parent()
					if (npc.is_dead || npc.is_unconscious):
						detection_code = "camera_body"
						detection_value += 10				
					elif (npc.is_hostaged || npc.is_escaping):
						detection_code = "camera_hostage"
						detection_value += 10		
					elif (npc.is_alerted):
						detection_code = "camera_alert"
						detection_value += 10
				elif (object.is_in_group("glass")):
					if (object.is_broken):
						detection_code = "camera_glass"
						detection_value += 10
				elif (object.is_in_group("bags")):
					detection_code = "camera_bag"
					detection_value += 10
				elif (object.is_in_group("drill")):
					if (object.get_parent().visible):
						detection_code = "camera_drill"
						detection_value += 10
					
			if (detection_value >= 100):
				break
	else:
		detection_value -= 2
		

func _on_Alert_timer_timeout():
	alarm_on()
	emit_signal("alerted",detection_code)

func alarm_on():
	is_alerted = true
	if (!is_broken):
		is_disabled = true
	
	targets = []
	
	$Alert_timer.stop()
	
	detection_value = 0
	$Detection_timer.stop()
