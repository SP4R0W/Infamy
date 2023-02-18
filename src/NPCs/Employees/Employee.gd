extends NPC

onready var agent: NavigationAgent2D = $NavigationAgent2D
onready var escape_ray: RayCast2D = $AnimatedSprite/EscapeRay

export var is_static: bool = false
export var speed: float = 500

var velocity: Vector2 = Vector2.ZERO

var cur_pos: int = 0

func on_ready():
	$AnimatedSprite.animation = "stand"
	
	yield(get_tree().create_timer(0.5),"timeout")
	
	agent.set_navigation(Game.map_nav)
	
	spawn_employee()
	.on_ready()
	
func spawn_employee():
	if (!is_static):
		var rest_point = Game.map_empl_restpoints.get_random_free_pos(cur_pos)
		
		cur_pos = rest_point[1]
		Game.map_empl_restpoints.set_locked(cur_pos)
		
		global_position = rest_point[0].global_position
		
		$AnimatedSprite.rotation_degrees = Game.map_empl_restpoints.positions_rotations[cur_pos]

		move_timer.wait_time = int(rand_range(3,7))
		move_timer.start()


func on_move():
	var rest_point = Game.map_empl_restpoints.get_random_free_pos(cur_pos)
	
	if (rest_point != []):
		Game.map_empl_restpoints.set_free(cur_pos)
		agent.set_target_location(rest_point[0].global_position)
		
		is_moving = true
		
		cur_pos = rest_point[1]
		
		Game.map_empl_restpoints.set_locked(cur_pos)
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
		$AnimatedSprite.animation = "stand"
		
		is_escaping = true
		agent.set_target_location(Game.map_escape_zone.global_position)
		is_hostaged = false
		can_interact = false
	else:
		retry_escape()
	
	.try_escape()
	
func reached():
	is_moving = false
	
	$AnimatedSprite.rotation_degrees = Game.map_empl_restpoints.positions_rotations[cur_pos]
	
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
	if (is_dead):
		$Interaction_panel/VBoxContainer/Action1.text = "Hold [F] to Bag"
		$Interaction_panel/VBoxContainer/Action2.hide()
		$Interaction_panel/VBoxContainer/Action3.hide()
		
		has_second_interaction = false
		has_third_interaction = false
	elif (is_unconscious):
		$Interaction_panel/VBoxContainer/Action1.text = "Hold [F] to Bag"
		$Interaction_panel/VBoxContainer/Action2.hide()
		$Interaction_panel/VBoxContainer/Action3.hide()
		
		has_second_interaction = false
		has_third_interaction = false
		
		if (has_disguise):
			$Interaction_panel/VBoxContainer/Action2.show()
			$Interaction_panel/VBoxContainer/Action2.text = "Hold [X] to Take Disguise"
			
			has_second_interaction = true
	elif (is_hostaged):
		if (!is_tied_hostage):
			$Interaction_panel/VBoxContainer/Action1.text = "Hold [F] to Tie"
		elif (is_tied_hostage && !is_following):
			$Interaction_panel/VBoxContainer/Action1.text = "Hold [F] to Move"
		else:
			$Interaction_panel/VBoxContainer/Action1.text = "Hold [F] to Stop"
			
		$Interaction_panel/VBoxContainer/Action2.hide()
		$Interaction_panel/VBoxContainer/Action3.hide()
		
		has_second_interaction = false
		has_third_interaction = false
			
		if (!was_interrogated):
			$Interaction_panel/VBoxContainer/Action2.show()
			$Interaction_panel/VBoxContainer/Action2.text = "Hold [X] to Interrogate"
			
			has_second_interaction = true
	
	.set_npc_interactions()
	
func check_interactions():
	if (has_focus && can_interact):
		$Interaction_panel/VBoxContainer/Action1.show()
		
		if (Input.is_action_pressed("interact1") && Game.player_can_interact):
			if (!Game.player_is_interacting):	
				if (is_dead || is_unconscious):
					action = "bag"
					if (Game.bodybags > 0):
						if (Game.player_bag == "empty"):
							$Interaction_timer.wait_time = 5
							$bag.play()
						else:
							Game.ui.update_popup("You are already carrying a bag!",2)
							
							Game.player_can_interact = false
							get_tree().create_timer(1).connect("timeout",Game,"stop_interaction_grace")
							
							return
					else:
						Game.ui.update_popup("You have no body bags!",2)
						
						Game.player_can_interact = false
						get_tree().create_timer(1).connect("timeout",Game,"stop_interaction_grace")
						
						return
				elif (is_hostaged && !is_tied_hostage):
					action = "tie"
					if (Game.handcuffs > 0):
						$Interaction_timer.wait_time = 1
						$tie.play()
					else:
						Game.ui.update_popup("You have no cable ties!",2)
						
						Game.player_can_interact = false
						get_tree().create_timer(1).connect("timeout",Game,"stop_interaction_grace")
						
						return
				elif (is_hostaged && is_tied_hostage && !is_following):
					action = "move"
					$Interaction_timer.wait_time = .5
				elif (is_hostaged && is_tied_hostage && is_following):
					action = "stop"
					$Interaction_timer.wait_time = .5
					
				Game.player_is_interacting = true
					
				$Interaction_timer.start()
				
				$Interaction_panel/VBoxContainer/Interaction_progress.show()

				Game.suspicious_interaction = true
				
				emit_signal("object_interaction_started",self,self.action)
		elif (Input.is_action_pressed("interact2") && Game.player_can_interact && has_second_interaction):
			if (!Game.player_is_interacting):
				if (is_unconscious && has_disguise):
					if (Game.player_disguise != "employee"):
						action = "disguise"
						$Interaction_timer.wait_time = 5
					else:
						Game.ui.update_popup("You already have this disguise!",2)
						
						Game.player_can_interact = false
						get_tree().create_timer(1).connect("timeout",Game,"stop_interaction_grace")
						
						return
				elif (is_hostaged && !was_interrogated):
					action = "interrogate"
					$Interaction_timer.wait_time = 4
					
				Game.player_is_interacting = true				
				$Interaction_timer.start()
				
				$Interaction_panel/VBoxContainer/Interaction_progress.show()
				
				Game.suspicious_interaction = true
				
				emit_signal("object_interaction_started",self,self.action)
		else:
			if (Game.player_is_interacting):
				
				Game.player_is_interacting = false
				$Interaction_timer.stop()
				
				$bag.stop()
				$tie.stop()
				
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
		
		$bag.stop()
		$tie.stop()
		
		if (action == "bag"):
			Game.bodybags -= 1
			Game.carry_bag("employee",has_disguise)
			queue_free()
		elif (action == "tie"):
			tie()
		elif (action == "move"):
			is_following = true
		elif (action == "stop"):
			is_following = false
		elif (action == "disguise"):
			Game.change_player_disguise("employee")
			has_disguise = false
		elif (action == "interrogate"):
			Game.map.interrogated(info)
	
	.finish_interactions()
	
func kill():	
	if (!is_dead):
		$AnimatedSprite.animation = "dead"
		
		.kill()

func knockout():
	if (!is_unconscious && !is_dead):
		$AnimatedSprite.animation = "knocked"
		
		.knockout()

func hostage():
	$AnimatedSprite.animation = "untied"
	
	.hostage()
	
func tie():
	$AnimatedSprite.animation = "tied"
	
	.tie()	

func alarm_on():
	if (!is_dead && !is_unconscious && !is_tied_hostage):
		$AnimatedSprite.animation = "stand"
		
		is_escaping = true
		agent.set_target_location(Game.map_escape_zone.global_position)
		is_hostaged = false
		can_interact = false
	
	.alarm_on()
