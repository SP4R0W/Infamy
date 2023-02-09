extends NPC

onready var agent: NavigationAgent2D = $NavigationAgent2D
onready var escape_ray: RayCast2D = $AnimatedSprite/EscapeRay

export(int, 4) var civ_type = 1
export var is_static: bool = false
export var speed: float = 500

export(NodePath) onready var start_point = get_node(start_point) as Position2D
export(NodePath) onready var end_point = get_node(end_point) as Position2D

var velocity: Vector2 = Vector2.ZERO

func on_ready():
	$AnimatedSprite.animation = str(civ_type) + "_stand"
	
	yield(get_tree().create_timer(0.5),"timeout")
	
	agent.set_navigation(Game.map_nav)
	
	random_look()
	spawn_civ()
	.on_ready()
	
func random_look():
	civ_type = int(rand_range(1,4))
	
	$AnimatedSprite.animation = str(civ_type) + "_stand"
	
func spawn_civ():
	if (!is_static):
		global_position = start_point.global_position
		
		agent.set_target_location(end_point.global_position)
		
		is_moving = true
	
func on_escape():
	escape_ray.cast_to = Vector2(1000,0)
	escape_ray.look_at(Game.player.global_position)
	escape_ray.enabled = true
	
	escape_ray.force_raycast_update()

	if (escape_ray.is_colliding()):
		var collider = escape_ray.get_collider()
		if (collider.is_in_group("Player")):
			retry_escape()
	else:
		try_escape()
		
	.on_escape()
	
func retry_escape():
	$Escape_timer.stop()
	$Escape_timer.start()
	
	.retry_escape()
	
func try_escape():
	var chance = int(rand_range(1,100))

	if (chance > 75):
		$AnimatedSprite.animation = str(civ_type) + "_stand"
		
		is_escaping = true
		agent.set_target_location(Game.map_escape_zone.global_position)
		is_hostaged = false
		can_interact = false
	else:
		retry_escape()
	
	.try_escape()
	
func reached():
	is_moving = false
	
	can_see = false
	visible = false
	
	$MoveTimer.wait_time = rand_range(3,5)
	$MoveTimer.start()
	
func on_move():
	random_look()
	
	global_position = start_point.global_position
		
	agent.set_target_location(end_point.global_position)
		
	is_moving = true
	can_see = true
	visible = true
	
	.on_move()
	
func escaped():
	emit_signal("alerted","hostage_escaped")
	
	queue_free()

func on_physics_process(delta: float):
	if (is_following):
		$AnimatedSprite.look_at(Game.player.global_position)
		
		if (global_position.distance_to(Game.player.global_position) <= 25):
			return
		else:
			var desired = global_position.direction_to(Game.player.global_position) * speed
			var steering = (desired - velocity) * delta * 4
			velocity += steering
			
			global_position += velocity * delta
	elif (!is_following && (is_moving || is_escaping)):
		var point = agent.get_final_location()
		
		if (global_position.distance_to(point) <= 10):
			if (is_moving):
				reached()
				return
			elif (is_escaping):
				escaped()
				return
	
		$AnimatedSprite.look_at(agent.get_next_location())
		
		var dir = global_position.direction_to(agent.get_next_location())
		
		var r_speed = speed
		if (is_escaping):
			r_speed = speed * 1.5
		
		var desired = dir * r_speed
		var steering = (desired - velocity) * delta * 4
		velocity += steering
		
		global_position += velocity * delta
				
	.on_physics_process(delta)
	
func set_npc_interactions():
	$Interaction_panel/VBoxContainer/Action2.hide()
	$Interaction_panel/VBoxContainer/Action3.hide()
	
	has_second_interaction = false
	has_third_interaction = false
	
	if (is_dead || is_unconscious):
		$Interaction_panel/VBoxContainer/Action1.text = "Hold [F] to Bag"
	elif (is_hostaged):
		if (!is_tied_hostage):
			$Interaction_panel/VBoxContainer/Action1.text = "Hold [F] to Tie"
		elif (is_tied_hostage && !is_following):
			$Interaction_panel/VBoxContainer/Action1.text = "Hold [F] to Move"
		else:
			$Interaction_panel/VBoxContainer/Action1.text = "Hold [F] to Stop"
	
	.set_npc_interactions()
	
func check_interactions():
	if (has_focus && can_interact):
		$Interaction_panel/VBoxContainer/Action1.show()
		
		if (Input.is_action_pressed("interact1") && Game.player_can_interact):
			if (!Game.player_is_interacting):
				Game.player_is_interacting = true
				
				if (is_dead || is_unconscious):
					action = "bag"
					if (Game.bodybags > 0):
						$Interaction_timer.wait_time = 5
					else:
						$Interaction_timer.wait_time = 0.1
				elif (is_hostaged && !is_tied_hostage):
					action = "tie"
					if (Game.handcuffs > 0):
						$Interaction_timer.wait_time = 1
					else:
						$Interaction_timer.wait_time = 0.1
				elif (is_hostaged && is_tied_hostage && !is_following):
					action = "move"
					$Interaction_timer.wait_time = .5
				elif (is_hostaged && is_tied_hostage && is_following):
					action = "stop"
					$Interaction_timer.wait_time = .5
					
				$Interaction_timer.start()
				
				$Interaction_panel/VBoxContainer/Interaction_progress.show()

				Game.suspicious_interaction = true
				
				emit_signal("object_interaction_started",self,self.action)
		else:
			if (Game.player_is_interacting):
				
				Game.player_is_interacting = false
				$Interaction_timer.stop()
				
				$Interaction_panel/VBoxContainer/Interaction_progress.hide()
				
				Game.suspicious_interaction = false
				
				emit_signal("object_interaction_aborted",self,self.action)
	elif (has_focus && !can_interact):
		$Interaction_panel/VBoxContainer/Action1.hide()
		$Interaction_panel/VBoxContainer/Action3.show()
	else:
		hide_panel()
	
	if (Game.player_is_interacting && has_focus):	
		$Interaction_panel/VBoxContainer/Interaction_progress.value = (($Interaction_timer.wait_time - $Interaction_timer.time_left) / $Interaction_timer.wait_time) * 100
	
	.check_interactions()

func finish_interactions():
	if (Game.player_is_interacting):
		Game.player_is_interacting = false
		$Interaction_panel/VBoxContainer/Interaction_progress.hide()
		
		Game.player_can_interact = false
		get_tree().create_timer(0.2).connect("timeout",Game,"stop_interaction_grace")
		
		Game.suspicious_interaction = false
			
		emit_signal("object_interaction_finished",self,self.action)
		
		if (action == "bag"):
			if (Game.bodybags > 0):
				Game.bodybags -= 1
				Game.carry_bag("civilian",false)
				queue_free()
			else:
				Game.ui.update_popup("You have no body bags!",2)
		elif (action == "tie"):
			is_tied_hostage = true
			tie()
		elif (action == "move"):
			is_following = true
		elif (action == "stop"):
			is_following = false
	
	.finish_interactions()
	
func kill():	
	$AnimatedSprite.animation = str(civ_type) + "_dead"
	
	.kill()

func knockout():	
	$AnimatedSprite.animation = str(civ_type) + "_knocked"
	
	.knockout()

func hostage():
	$AnimatedSprite.animation = str(civ_type) + "_untied"
	
	.hostage()
	
func tie():
	$AnimatedSprite.animation = str(civ_type) + "_tied"
	
	.tie()	

func alarm_on():
	if (!is_dead && !is_unconscious && !is_tied_hostage):
		$AnimatedSprite.animation = str(civ_type) + "_stand"
		
		is_escaping = true
		agent.set_target_location(Game.map_escape_zone.global_position)
		is_hostaged = false
		can_interact = false
	
	.alarm_on()
