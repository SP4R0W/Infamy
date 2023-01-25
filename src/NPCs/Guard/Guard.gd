extends NPC

onready var agent: NavigationAgent2D = $NavigationAgent2D
onready var escape_ray: RayCast2D = $AnimatedSprite/EscapeRay

export var is_static: bool = false
export var is_camera_operator: bool = false
export var speed: float = 500

var velocity: Vector2 = Vector2.ZERO

var cur_pos: int = 0

func on_ready():
	yield(get_tree().create_timer(0.5),"timeout")
	
	agent.set_navigation(Game.map_nav)
	
	spawn_guard()
	.on_ready()
	
func spawn_guard():
	if (!is_static):
		var rest_point = Game.map_guard_restpoints.get_random_free_pos(cur_pos)
		
		cur_pos = rest_point[1]
		Game.map_guard_restpoints.set_locked(cur_pos)
		
		global_position = rest_point[0].global_position
		
		$AnimatedSprite.rotation_degrees = Game.map_guard_restpoints.positions_rotations[cur_pos]

		move_timer.wait_time = int(rand_range(3,7))
		move_timer.start()


func on_move():
	var rest_point = Game.map_guard_restpoints.get_random_free_pos(cur_pos)
	
	if (rest_point != []):
		Game.map_guard_restpoints.set_free(cur_pos)
		agent.set_target_location(rest_point[0].global_position)
		
		is_moving = true
		
		cur_pos = rest_point[1]
		
		Game.map_guard_restpoints.set_locked(cur_pos)
	else:
		move_timer.wait_time = int(rand_range(5,10))
		move_timer.start()
	
	.on_move()
	
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
		is_escaping = true
		agent.set_target_location(Game.map_escape_zone.global_position)
		is_hostaged = false
		can_interact = false
	else:
		retry_escape()
	
	.try_escape()
	
func reached():
	is_moving = false
	
	$AnimatedSprite.rotation_degrees = Game.map_guard_restpoints.positions_rotations[cur_pos]
	
	move_timer.wait_time = int(rand_range(5,10))
	move_timer.start()	
	
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
			elif (is_escaping):
				escaped()
	
		$AnimatedSprite.look_at(agent.get_next_location())
		
		var dir = global_position.direction_to(agent.get_next_location())
		
		var desired = dir * speed
		var steering = (desired - velocity) * delta * 4
		velocity += steering
		
		global_position += velocity * delta
				
	.on_physics_process(delta)
	
func set_npc_interactions():
	if (is_dead):
		$Interaction_panel/VBoxContainer/Action1.text = "Hold [F] to Bag"
		$Interaction_panel/VBoxContainer/Action2.hide()
		$Interaction_panel/VBoxContainer/Action3.hide()
	elif (is_unconscious):
		$Interaction_panel/VBoxContainer/Action1.text = "Hold [F] to Bag"
		$Interaction_panel/VBoxContainer/Action2.hide()
		$Interaction_panel/VBoxContainer/Action3.hide()
		
		if (has_disguise):
			$Interaction_panel/VBoxContainer/Action2.show()
			$Interaction_panel/VBoxContainer/Action2.text = "Hold [X] to Take Disguise"
	elif (is_hostaged):
		if (!is_tied_hostage):
			$Interaction_panel/VBoxContainer/Action1.text = "Hold [F] to Tie"
		elif (is_tied_hostage && !is_following):
			$Interaction_panel/VBoxContainer/Action1.text = "Hold [F] to Move"
		else:
			$Interaction_panel/VBoxContainer/Action1.text = "Hold [F] to Stop"
			
		$Interaction_panel/VBoxContainer/Action2.hide()
		$Interaction_panel/VBoxContainer/Action3.hide()
			
		if (!was_interrogated):
			$Interaction_panel/VBoxContainer/Action2.show()
			$Interaction_panel/VBoxContainer/Action2.text = "Hold [X] to Interrogate"
	
	.set_npc_interactions()
	
func check_interactions():
	if (has_focus && can_interact):
		if (Input.is_action_pressed("interact1") && Game.player_can_interact):
			if (!Game.player_is_interacting):
				Game.player_is_interacting = true
				
				if (is_dead || is_unconscious):
					action = "bag"
					$Interaction_timer.wait_time = 5
				elif (is_hostaged && !is_tied_hostage):
					action = "tie"
					$Interaction_timer.wait_time = 1
				elif (is_hostaged && is_tied_hostage && !is_following):
					action = "move"
					$Interaction_timer.wait_time = .5
				elif (is_hostaged && is_tied_hostage && is_following):
					action = "stop"
					$Interaction_timer.wait_time = .5
					
				$Interaction_timer.start()
				
				$Interaction_panel/VBoxContainer/Interaction_progress.show()

				Game.suspicious_interaction = true
				
				emit_signal("object_interaction_started",self.name,self.action)
		elif (Input.is_action_pressed("interact2") && Game.player_can_interact):
			if (!Game.player_is_interacting && Game.get_amount_of_equipment("c4") > 0):
				Game.player_is_interacting = true
				
				if (is_unconscious && has_disguise):
					action = "disguise"
					$Interaction_timer.wait_time = 5
				elif (is_hostaged && !was_interrogated):
					action = "interrogate"
					$Interaction_timer.wait_time = 4
					
				$Interaction_timer.start()
				
				$Interaction_panel/VBoxContainer/Interaction_progress.show()
				
				Game.suspicious_interaction = true
				
				emit_signal("object_interaction_started",self.name,self.action)
		else:
			if (Game.player_is_interacting):
				
				Game.player_is_interacting = false
				$Interaction_timer.stop()
				
				$Interaction_panel/VBoxContainer/Interaction_progress.hide()
				
				Game.suspicious_interaction = false
				
				emit_signal("object_interaction_aborted",self.name,self.action)
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
			
		emit_signal("object_interaction_finished",self.name,self.action)
		
		if (action == "bag"):
			Game.carry_bag("guard",has_disguise)
			queue_free()
		elif (action == "tie"):
			is_tied_hostage = true
		elif (action == "move"):
			is_following = true
		elif (action == "stop"):
			is_following = false
		elif (action == "disguise"):
			Game.change_player_disguise("guard")
			has_disguise = false
		elif (action == "interrogate"):
			pass
	
	.finish_interactions()
	
func kill():
	if (is_camera_operator):
		get_tree().call_group("Camera","alarm_on")
	
	.kill()

func knockout():
	if (is_camera_operator):
		get_tree().call_group("Camera","alarm_on")
	
	.knockout()

func hostage():
	if (is_camera_operator):
		get_tree().call_group("Camera","alarm_on")
	
	.hostage()