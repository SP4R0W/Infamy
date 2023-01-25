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
			if (!Game.player_is_interacting && Game.player_inventory.has(item_needed)):
				Game.player_is_interacting = true
				action = "open"
				
				emit_signal("object_interaction_started",self.name,self.action)
				
				$Interaction_timer.wait_time = .5
					
				$Interaction_timer.start()
				
				$Interaction_panel/VBoxContainer/Interaction_progress.show()
				
				if (!disguises_needed.has(Game.player_disguise)):
					Game.suspicious_interaction = true
		elif (Input.is_action_pressed("interact2") && Game.player_can_interact):
			if (!Game.player_is_interacting && Game.get_amount_of_equipment("c4") > 0):
				Game.player_is_interacting = true
				action = "c4"
				
				emit_signal("object_interaction_started",self.name,self.action)
				
				$Interaction_timer.wait_time = 2
				$Interaction_timer.start()
				
				$Interaction_panel/VBoxContainer/Interaction_progress.show()
				
				Game.suspicious_interaction = true
		elif (Input.is_action_pressed("interact3") && Game.player_can_interact):
			if (!Game.player_is_interacting && Game.get_amount_of_equipment("ecm") > 0 && can_use_ecm):
				Game.player_is_interacting = true
				action = "ecm"
				
				emit_signal("object_interaction_started",self.name,self.action)
				
				$Interaction_timer.wait_time = 2
				$Interaction_timer.start()
				
				$Interaction_panel/VBoxContainer/Interaction_progress.show()
				
				Game.suspicious_interaction = true
		else:
			if (Game.player_is_interacting):
				emit_signal("object_interaction_aborted",self.name,self.action)
				
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
			
		emit_signal("object_interaction_finished",self.name,self.action)
		
		if (action == "open"):
			if (is_closed):
				is_closed = false
				
				$Interaction_panel/VBoxContainer/Action1.text = "Hold [F] to Close"
				if (is_equal_approx(original_rotation,90)):
					$Sprite.rotation_degrees = 0
				elif (is_equal_approx(original_rotation,0)):
					$Sprite.rotation_degrees = 90
					
				$Sprite.modulate = Color(0,1,0,1)
					
				set_collision_layer_bit(12,false)
				get_tree().call_group("Detection","add_exception",self)
				get_tree().call_group("Detection","add_exception",$Interaction_hitbox)
			else:
				$Interaction_panel/VBoxContainer/Action1.text = "Hold [F] to Open (requires " + item_needed_name + ")"
				
				$Sprite.rotation_degrees = original_rotation
				$Sprite.modulate = Color(1,0,0,1)
					
				set_collision_layer_bit(12,true)
				get_tree().call_group("Detection","remove_exception",self)
				get_tree().call_group("Detection","remove_exception",$Interaction_hitbox)
		elif (action == "c4"):
			Game.use_player_equipment("c4")
			can_interact = false
			
			$C4.show()
			$C4_noise.play()
			$C4_timer.start()
		elif (action == "ecm"):
			Game.use_player_equipment("ecm")
			can_interact = false
			
			if (is_equal_approx(original_rotation,90)):
				$Sprite.rotation_degrees = 0
			elif (is_equal_approx(original_rotation,0)):
				$Sprite.rotation_degrees = 90
					
			$Sprite.modulate = Color(0,1,0,1)
					
			set_collision_layer_bit(12,false)
			get_tree().call_group("Detection","add_exception",self)
			get_tree().call_group("Detection","add_exception",$Interaction_hitbox)


func _on_C4_timer_timeout():
	beep_counter += 1
	
	if (beep_counter < max_beeps):
		$C4_noise.play()
		$C4_timer.start()
	else:
		$C4.hide()
		$Explosion.play()
		
		var noise = noise_scene.instance()
		noise.radius = 1000
		noise.time = 0.1
		add_child(noise)
		
		if (is_equal_approx(original_rotation,90)):
			$Sprite.rotation_degrees = 0
		elif (is_equal_approx(original_rotation,0)):
			$Sprite.rotation_degrees = 90
					
		set_collision_layer_bit(12,false)
		get_tree().call_group("Detection","add_exception",self)
		get_tree().call_group("Detection","add_exception",$Interaction_hitbox)