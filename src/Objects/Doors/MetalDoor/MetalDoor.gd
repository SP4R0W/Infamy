extends StaticBody2D

var noise_scene = preload("res://src/Zones/AlertZone/AlertZone.tscn")

signal object_interaction_started(object,action)
signal object_interaction_aborted(object,action)
signal object_interaction_finished(object,action)

export var disguises_needed = ["guard","employee"]

var has_focus: bool = false

var is_lockpicked: bool = false
var is_closed: bool = true

export var can_interact: bool = true

var beep_counter = 0
var max_beeps = 4

var original_rotation: float
var action: String

func _ready():
	$C4.hide()
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
			if (!Game.player_is_interacting):
				Game.player_is_interacting = true
				action = "open"
				
				emit_signal("object_interaction_started",self,self.action)
				
				if (!is_lockpicked):
					$Interaction_timer.wait_time = 5
					Game.suspicious_interaction = true
				else:
					$Interaction_timer.wait_time = .5
					
				$Interaction_timer.start()
				
				$Interaction_panel/VBoxContainer/Interaction_progress.show()
			
		elif (Input.is_action_pressed("interact2") && Game.player_can_interact):
			if (!Game.player_is_interacting && Game.get_amount_of_equipment("C4") > 0):
				Game.player_is_interacting = true
				action = "c4"
				
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
			if (!is_lockpicked):
				is_lockpicked = true
				
			if (is_closed):
				is_closed = false
				
				$Interaction_panel/VBoxContainer/Action1.text = "Hold [F] to Close"
				if (is_equal_approx(original_rotation,90)):
					$Sprite.rotation_degrees = 0
				elif (is_equal_approx(original_rotation,0)):
					$Sprite.rotation_degrees = 90
					
				set_collision_layer_bit(12,false)
				get_tree().call_group("Detection","add_exception",self)
				get_tree().call_group("Detection","add_exception",$Interaction_hitbox)
			else:
				is_closed = true
				$Interaction_panel/VBoxContainer/Action1.text = "Hold [F] to Open"
				
				$Sprite.rotation_degrees = original_rotation
					
				set_collision_layer_bit(12,true)
				get_tree().call_group("Detection","remove_exception",self)
				get_tree().call_group("Detection","remove_exception",$Interaction_hitbox)
		elif (action == "c4"):
			Game.use_player_equipment("C4")
			can_interact = false
			
			$C4.show()
			$C4_noise.play()
			$C4_timer.start()


func _on_C4_timer_timeout():
	beep_counter += 1
	
	if (beep_counter < max_beeps):
		$C4_noise.play()
		$C4_timer.start()
	else:
		$C4.hide()
		$Explosion.play()
		
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
		get_tree().call_group("Detection","add_exception",self)
		get_tree().call_group("Detection","add_exception",$Interaction_hitbox)


func _on_NPC_open_area_entered(area):
	if (area.is_in_group("hitbox_npc")):
		if (is_closed):
			is_closed = false
			
			if (is_equal_approx(original_rotation,90)):
				$Sprite.rotation_degrees = 0
			elif (is_equal_approx(original_rotation,0)):
				$Sprite.rotation_degrees = 90
				
			set_collision_layer_bit(12,false)
			get_tree().call_group("Detection","add_exception",self)
			get_tree().call_group("Detection","add_exception",$Interaction_hitbox)
			
			yield(get_tree().create_timer(2),"timeout")
			
			is_closed = true
			
			$Sprite.rotation_degrees = original_rotation
				
			set_collision_layer_bit(12,true)
			get_tree().call_group("Detection","remove_exception",self)
			get_tree().call_group("Detection","remove_exception",$Interaction_hitbox)
