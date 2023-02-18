extends StaticBody2D

var noise_scene = preload("res://src/Zones/AlertZone/AlertZone.tscn")

signal object_interaction_started(object,action)
signal object_interaction_aborted(object,action)
signal object_interaction_finished(object,action)

export var disguises_needed = ["guard"]

var has_focus: bool = false

var is_closed: bool = true

export var can_interact: bool = true
export var can_use_ecm: bool = false
var is_player_inside: bool = false
var is_broken: bool = false

export var item_needed_name: String = "Blue Keycard"
export var item_needed: String = "b_keycard"

var beep_counter = 0
var max_beeps = 4

var original_rotation: float
var action: String

func _ready():
	if (can_use_ecm):
		$Interaction_panel/VBoxContainer/Action3.show()
	else:
		$Interaction_panel/VBoxContainer/Action3.hide()
	
	$C4.hide()
	$Interaction_panel/VBoxContainer/Action1.text = "Hold [F] to Open (requires " + item_needed_name + ")"
	original_rotation = $Sprite.rotation_degrees
	
	$Interaction_panel.hide()
	$Interaction_panel/VBoxContainer/Interaction_progress.hide()

func show_panel():
	has_focus = true
	$Interaction_panel.show()
	$Interaction_panel/VBoxContainer/Interaction_progress.hide()
	
func hide_panel():
	has_focus = false
	$Interaction_panel.hide()

func _process(delta):
	if (has_focus && can_interact):
		if (Input.is_action_pressed("interact1") && Game.player_can_interact):
			if (!is_player_inside):
				if (!Game.player_is_interacting && Game.player_inventory.has(item_needed)):
					Game.player_is_interacting = true
					action = "open"
					
					emit_signal("object_interaction_started",self,self.action)
					
					$Interaction_timer.wait_time = .5
						
					$Interaction_timer.start()
					
					$Interaction_panel/VBoxContainer/Interaction_progress.show()
					
					if (!disguises_needed.has(Game.player_disguise)):
						Game.suspicious_interaction = true
			else:
				Game.ui.update_popup("Can't interact with doors while inside them",2)
							
				Game.player_can_interact = false
				get_tree().create_timer(1).connect("timeout",Game,"stop_interaction_grace")
							
				return
		elif (Input.is_action_pressed("interact2") && Game.player_can_interact):
			if (!Game.player_is_interacting && is_closed):
				if (!Game.get_amount_of_equipment("C4") > 0):
					Game.ui.update_popup("You have no C4 remaining!",2)
					
					Game.player_can_interact = false
					get_tree().create_timer(1).connect("timeout",Game,"stop_interaction_grace")
					
					return
				
				Game.player_is_interacting = true
				action = "c4"
				
				emit_signal("object_interaction_started",self,self.action)
				
				$Interaction_timer.wait_time = 2
				$Interaction_timer.start()
				
				$Interaction_panel/VBoxContainer/Interaction_progress.show()
				
				Game.suspicious_interaction = true
		elif (Input.is_action_pressed("interact3") && Game.player_can_interact):
			if (!Game.player_is_interacting && can_use_ecm && is_closed):
				if (!Game.get_amount_of_equipment("ECM") > 0):
					Game.ui.update_popup("You have no ECM remaining!",2)
					
					Game.player_can_interact = false
					get_tree().create_timer(1).connect("timeout",Game,"stop_interaction_grace")
					
					return
				
				Game.player_is_interacting = true
				action = "ecm"
				
				emit_signal("object_interaction_started",self,self.action)
				
				$Interaction_timer.wait_time = 2
				$Interaction_timer.start()
				
				$Interaction_panel/VBoxContainer/Interaction_progress.show()
				
				Game.suspicious_interaction = true
		else:
			if (Game.player_is_interacting):
				emit_signal("object_interaction_aborted",self,self.action)
				
				Game.player_is_interacting = false
				$Interaction_timer.stop()
				
				$Interaction_panel/VBoxContainer/Interaction_progress.hide()
				
				Game.suspicious_interaction = false
	else:	
		hide_panel()
	
	if (Game.player_is_interacting && has_focus):	
		$Interaction_panel/VBoxContainer/Interaction_progress.value = (($Interaction_timer.wait_time - $Interaction_timer.time_left) / $Interaction_timer.wait_time) * 100

func _on_Interaction_timer_timeout():
	if (Game.player_is_interacting):
		Game.player_is_interacting = false
		$Interaction_panel/VBoxContainer/Interaction_progress.hide()
		
		Game.player_can_interact = false
		get_tree().create_timer(0.2).connect("timeout",Game,"stop_interaction_grace")
		
		Game.suspicious_interaction = false
			
		emit_signal("object_interaction_finished",self,self.action)
		
		if (action == "open"):
			if (is_closed):
				is_closed = false
					
				$Interaction_panel/VBoxContainer/Action2.hide()
				$Interaction_panel/VBoxContainer/Action3.hide()
					
				$Interaction_panel/VBoxContainer/Action1.text = "Hold [F] to Close"
				if (is_equal_approx(original_rotation,90)):
					$Sprite.rotation_degrees = 0
				elif (is_equal_approx(original_rotation,0)):
					$Sprite.rotation_degrees = 90
						
				$Sprite.modulate = Color(0,1,0,1)
						
				set_collision_layer_bit(12,false)
				get_tree().call_group("Detection","add_exception",$Interaction_hitbox)
			else:
				is_closed = true
				$Interaction_panel/VBoxContainer/Action1.text = "Hold [F] to Open (requires " + item_needed_name + ")"
				
				$Interaction_panel/VBoxContainer/Action2.show()
				$Interaction_panel/VBoxContainer/Action3.show()
				
				$Sprite.rotation_degrees = original_rotation
				$Sprite.modulate = Color(1,0,0,1)
					
				set_collision_layer_bit(12,true)
				get_tree().call_group("Detection","remove_exception",$Interaction_hitbox)
		elif (action == "c4"):
			Game.use_player_equipment("C4")
			can_interact = false
			
			$C4.show()
			$C4_noise.play()
			$C4_timer.start()
		elif (action == "ecm"):
			Game.use_player_equipment("ECM")
			can_interact = false
			
			if (is_equal_approx(original_rotation,90)):
				$Sprite.rotation_degrees = 0
			elif (is_equal_approx(original_rotation,0)):
				$Sprite.rotation_degrees = 90
					
			$Sprite.modulate = Color(0,1,0,1)
					
			set_collision_layer_bit(12,false)
			get_tree().call_group("Detection","add_exception",$Interaction_hitbox)


func _on_C4_timer_timeout():
	beep_counter += 1
	
	if (beep_counter < max_beeps):
		$C4_noise.play()
		$C4_timer.start()
	else:
		$C4.hide()
		$Explosion.play()

		show()
		set_process(true)
		
		is_broken = true
		
		var noise = noise_scene.instance()
		noise.radius = 4000
		noise.time = 0.1
		add_child(noise)
		
		$NPC_open.call_deferred("queue_free")
		
		if (is_equal_approx(original_rotation,90)):
			$Sprite.rotation_degrees = 0
		elif (is_equal_approx(original_rotation,0)):
			$Sprite.rotation_degrees = 90
					
		set_collision_layer_bit(12,false)
		get_tree().call_group("Detection","remove_exception",$Interaction_hitbox)


func _on_NPC_open_area_entered(area):
	if (area.is_in_group("hitbox_npc")):
		var npc = area.get_parent().get_parent()
		
		if (!npc.is_hostaged && !npc.is_dead && !npc.is_unconscious && is_closed):
			is_closed = false
			can_interact = false
			
			if (is_equal_approx(original_rotation,90)):
				$Sprite.rotation_degrees = 0
			elif (is_equal_approx(original_rotation,0)):
				$Sprite.rotation_degrees = 90
			
			$Sprite.modulate = Color(1,0,0,1)
			
			set_collision_layer_bit(12,false)
			get_tree().call_group("Detection","add_exception",$Interaction_hitbox)


func _on_Collision_hitbox_body_entered(body):
	if (body.is_in_group("Player")):
		is_player_inside = true


func _on_Collision_hitbox_body_exited(body):
	if (body.is_in_group("Player")):
		is_player_inside = false


func _on_VisibilityNotifier2D_screen_entered():
	if (!is_broken):
		show()
		set_process(true)


func _on_VisibilityNotifier2D_screen_exited():
	if (!is_broken):
		hide()
		set_process(false)
