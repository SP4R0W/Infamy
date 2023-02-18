extends Node2D
class_name NPC

var bullet_scene = preload("res://src/Weapons/Enemy_bullet.tscn")
var noise_scene = preload("res://src/Zones/AlertZone/AlertZone.tscn")

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

var action: String = "loop"

var has_focus: bool = false

var exceptions = []

var raycasts = []
var targets = []

var base_detection_speed = 0.1

var detection_code: String = "None"
var detection_value: int = 0

var is_seeing: bool = false
var is_detecting: bool = false
var is_detecting_player_disguise: bool = false

var is_shooting: bool = false
var can_shoot: bool = false
var can_shoot_visible: bool = false

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
	
	get_tree().call_group("Detection","add_exception",$Interaction_hitbox)
	
func draw_fov():
	$AnimatedSprite/Detect/CollisionPolygon2D.polygon = fov_polygons[Game.difficulty]
	
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
	for exception in exceptions:
		ray.add_exception(exception)
	
	rays.add_child(ray)
	var dict = {"ray_cast":ray,"detecting":false,"seeing":false,"detection_value":0,"object":null}
	raycasts.append(dict)
	
	return dict
	
func add_exception(object):
	if (!exceptions.has(object)):
		exceptions.append(object)
			
		for x in range(rays.get_child_count()):
			var ray: RayCast2D = rays.get_child(x)
			ray.add_exception(object)
			
		if (targets.has(object)):
			targets.erase(object)
		
func remove_exception(object):
	if (exceptions.has(object) && object != self.get_node("Interaction_hitbox")):
		exceptions.erase(object)
		
		for x in range(rays.get_child_count()):
			var ray: RayCast2D = rays.get_child(x)
			ray.remove_exception(object)
		
func set_npc_interactions():
	if (!can_interact):
		return

				
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
						ray_dict["seeing"] = false
						ray_dict["object"] = null
						continue
					
					var ray: RayCast2D = ray_dict["ray_cast"]
					ray.enabled = true
						
					ray.look_at(target.global_position)
					ray.cast_to = Vector2($AnimatedSprite.global_position.distance_to(target.global_position),0)
					ray.force_raycast_update()

					ray_dict["seeing"] = true
					ray_dict["object"] = target

		if (targets.size() == 0):
			for x in range(rays.get_child_count()):
				var ray: RayCast2D = rays.get_child(x)
				raycasts[x]["seeing"] = false
				ray.enabled = false
		elif (rays.get_child_count() > targets.size()):
			for x in range(rays.get_child_count() - 1,targets.size(),-1):
				var ray: RayCast2D = rays.get_child(x)
				raycasts[x]["seeing"] = false
				ray.enabled = false
		
		var seeing = []
		var detecting = []
		for ray in raycasts:
			seeing.append(ray["seeing"])
			detecting.append(ray["detecting"])
			
		if (seeing.has(true)):
			is_seeing = true
		else:
			is_seeing = false
			
		if (detecting.has(true)):
			is_detecting = true
			show()
		else:
			is_detecting = false

		if (is_seeing):
			for ray in raycasts:
				check_if_ray_sees_target(ray)
				
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
						
					if (!get_tree().get_nodes_in_group("detectable").has(target)):
						targets.erase(target)
						ray_dict["seeing"] = false
						ray_dict["object"] = null
						continue
					
					var ray = ray_dict["ray_cast"]
					ray.enabled = true
						
					ray.look_at(target.global_position)
					ray.cast_to = Vector2($AnimatedSprite.global_position.distance_to(target.global_position),0)
					ray.force_raycast_update()

					if (ray.is_colliding()):
						var collider = ray.get_collider()
						if (collider.is_in_group("Player")):
							ray_dict["seeing"] = true
							ray_dict["object"] = collider
							$AnimatedSprite.look_at(collider.global_position)
							ray.force_raycast_update()
						else:
							ray_dict["seeing"] = false
							ray_dict["object"] = null
					else:
						ray_dict["seeing"] = false
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
			values.append(ray["seeing"])
			
		if (values.has(true)):
			can_shoot = true
		else:
			can_shoot = false
			
		if (can_shoot && !is_shooting && can_shoot_visible):
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
	
func check_if_ray_sees_target(dict):
	var target = dict["object"]
	var ray = dict["ray_cast"]

	if (ray.is_colliding()):
		var collider = ray.get_collider()
		if (collider == target && target in targets):
			if (target.is_in_group("Player")):
				if (Game.player_status != Game.player_statuses.NORMAL):
					dict["detecting"] = true
					detection_code = npc_name + "_player"
					if (Game.player_status == Game.player_statuses.DISGUISED):
						dict["detection_value"] = 1.2 * ceil((float(Game.difficulty) + 1) / 2)
					else:
						dict["detection_value"] = 2.5 * (Game.difficulty + 1)
				else:
					dict["detecting"] = false
					dict["object"] = null
			elif (target.is_in_group("npc")):
				var npc = target.get_parent()
				if (npc.is_dead || npc.is_unconscious):
					dict["detecting"] = true
					detection_code = npc_name  + "_body"
					dict["detection_value"] = 3 * (Game.difficulty + 1)
				elif (npc.is_hostaged || npc.is_escaping):
					dict["detecting"] = true
					detection_code =  npc_name  + "_hostage"
					dict["detection_value"] = 3 * (Game.difficulty + 1)	
				elif (npc.is_alerted):
					detection_code =  npc_name  + "_alert"
					dict["detecting"] = true
					dict["detection_value"] = 3 * (Game.difficulty + 1)
			elif (target.is_in_group("Camera")):
				if (target.get_parent().is_broken && target.get_parent().visible):
					detection_code = npc_name  + "_camera"
					dict["detecting"] = true
					dict["detection_value"] = 3 * (Game.difficulty + 1)
			elif (target.is_in_group("bags")):
					detection_code = npc_name  + "_bag"
					dict["detecting"] = true
					dict["detection_value"] = 3 * (Game.difficulty + 1)
			elif (target.is_in_group("drill")):
				if (target.get_parent().visible):
					detection_code = npc_name  + "_drill"
					dict["detecting"] = true
					dict["detection_value"] = 3 * (Game.difficulty + 1)
				else:
					dict["detecting"] = false
					dict["object"] = null
			elif (target.is_in_group("door")):
				if (target.get_parent().is_broken):
					detection_code = npc_name  + "_door"
					dict["detecting"] = true
					dict["detection_value"] = 3 * (Game.difficulty + 1)
			else:
				dict["detecting"] = false
				dict["detection_value"] = 0
				dict["object"] = null
		else:
			dict["detecting"] = false
			dict["detection_value"] = 0
			dict["object"] = null
	else:
		dict["detecting"] = false
		dict["detection_value"] = 0
		dict["object"] = null
		
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
			alerted()
			$Detection_timer.stop()
			$MoveTimer.stop()
			is_moving = false
			
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
				if (ray["object"] in targets):
					detection_value += ray["detection_value"]
					
					if (!$detection.playing):
						$detection.play()
							
					if (detection_value >= 100):
						$detection.stop()
						$detected.play()
						$Detection_timer.stop()
						break
				else:
					ray["detecting"] = false
					ray["object"] = null
	else:
		if (detection_value > 0):
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
		if (ray["seeing"]):
			if (ray["object"] in targets):
				target = ray["object"]
			else:
				ray["object"] = null
	
	if (target != null):
		$AnimatedSprite.look_at(target.global_position)
		
		var bullet = bullet_scene.instance()
		bullet.accuracy = 100
		Game.game_scene.add_child(bullet)
		bullet.target = target
		bullet.global_position = $AnimatedSprite/BulletOrigin.global_position
		bullet.damage = 2.5 * (Game.difficulty + 1)
		
		var noise = noise_scene.instance()
		noise.radius = 4000
		noise.time = 0.1
		Game.game_scene.add_child(noise)
		noise.global_position = $AnimatedSprite.global_position
		
		$shoot.play()

	$Shoot_timer.start()
		
func alerted():
	$AnimatedSprite.animation = "shoot"
	
	get_tree().call_group("Detection","remove_exception",$Interaction_hitbox)
			
func kill():
	if (!is_dead):
		if (is_tied_hostage):
			Game.hostages -= 1
		
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
		
		$detection.stop()
		$detected.stop()
		
		emit_signal("npc_dead",self)
		get_tree().call_group("Detection","remove_exception",$Interaction_hitbox)
		
		if (Game.is_game_loud):
			$Dissappear.start()
			
	
func knockout():
	if (!is_unconscious && !is_dead):
		if (is_tied_hostage):
			Game.hostages -= 1
			
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
		
		$detection.stop()
		$detected.stop()
		
		$knockout.play()
		
		emit_signal("npc_knocked",self)
		
		get_tree().call_group("Detection","remove_exception",$Interaction_hitbox)
		
	
func hostage():
	can_interact = true
	
	is_following = false
	is_escaping = false
	is_moving = false
	
	is_hostaged = true
	
	$MoveTimer.stop()
	$Escape_timer.start()
	$Alert_timer.stop()
	
	$detection.stop()
	
	if (!is_alerted):
		$detected.play()
	
	emit_signal("npc_hostaged",self)
	
	get_tree().call_group("Detection","remove_exception",$Interaction_hitbox)

func tie():
	if (Game.handcuffs > 0):
		Game.handcuffs -= 1
		Game.hostages += 1
		
		is_tied_hostage = true
		
		$Escape_timer.stop()
	else:
		Game.ui.update_popup("You have no handcuffs!",2)
	
func interrogate():
	was_interrogated = true

func _on_Detect_area_entered(area):
	if (!is_alerted):
		if (area.is_in_group("detectable") && area != $Interaction_hitbox):
			if (!targets.has(area) && targets.size() < Game.max_exceptions):
				targets.append(area)
	else:
		if (area.is_in_group("shootable")):
			if (!targets.has(area) && targets.size() < Game.max_exceptions):
				targets.append(area)		
				
func _on_Detect_area_exited(area):
	if (targets.has(area)):
		targets.erase(area)

func _on_Detect_body_entered(body):
	if (!targets.has(body)):
		if (body.is_in_group("detectable")):
			if (targets.size() < Game.max_exceptions):
				targets.append(body)
			else:
				if (body.is_in_group("Player")):
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
	$MoveTimer.stop()
	is_moving = false
	
	if (is_dead):
		$Dissappear.start()

func _on_Shoot_timer_timeout():
	is_shooting = false

func noise_heard():
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
		$Alert_timer.start()
		
	detection_code = npc_name + "_noise"

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


func _on_VisibilityNotifier2D_screen_entered():
	can_shoot_visible = true
	show()

func _on_VisibilityNotifier2D_screen_exited():
	if (!is_dead && !is_unconscious && !is_hostaged && !is_escaping && !is_alerted && !is_detecting):
		can_shoot_visible = false
		hide()


func _on_Dissappear_timeout():
	get_tree().call_group("Detection","remove_exception",$Interaction_hitbox)
	queue_free()
