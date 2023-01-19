extends StaticBody2D

signal object_interaction_started(object,action)
signal object_interaction_aborted(object,action)
signal object_interaction_finished(object,action)

export var disguises_needed = []

var has_focus: bool = false

export var can_interact: bool = true
export var item_stored: String = "none"

var beep_counter = 0
var max_beeps = 4

var action: String

func _ready():
	if (name.find("up") != -1):
		$Door.rotation_degrees = 0
	elif (name.find("down") != -1):
		$Door.rotation_degrees = 180
	elif (name.find("left") != -1):
		$Door.rotation_degrees = -90
	elif (name.find("right") != -1):
		$Door.rotation_degrees = 90
	
	$Drill.hide()
	$C4.hide()

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
				action = "drill"
				
				emit_signal("object_interaction_started",self.name,self.action)

				$Interaction_timer.wait_time = 2
				Game.suspicious_interaction = true
					
				$Interaction_timer.start()
				
				$Interaction_panel/VBoxContainer/Interaction_progress.show()
			
		elif (Input.is_action_pressed("interact2") && Game.player_can_interact):
			if (!Game.player_is_interacting):
				Game.player_is_interacting = true
				action = "lockpick"
				
				emit_signal("object_interaction_started",self.name,self.action)
				
				$Interaction_timer.wait_time = 10
				$Interaction_timer.start()
				
				$Interaction_panel/VBoxContainer/Interaction_progress.show()
				
				Game.suspicious_interaction = true
		elif (Input.is_action_pressed("interact3") && Game.player_can_interact):
			if (!Game.player_is_interacting && Game.get_amount_of_equipment("c4") > 0):
				Game.player_is_interacting = true
				action = "c4"
				
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
		can_interact = false
		Game.player_is_interacting = false
		$Interaction_panel/VBoxContainer/Interaction_progress.hide()
		
		Game.player_can_interact = false
		get_tree().create_timer(0.2).connect("timeout",Game,"stop_interaction_grace")
		
		Game.suspicious_interaction = false
			
		emit_signal("object_interaction_finished",self.name,self.action)
		
		if (action == "drill"):
			$Drill.show()
			$Drill.start_drill()
		elif (action == "lockpick"):
			open_safe()
		elif (action == "c4"):
			Game.use_player_equipment("c4")
			
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
		
		open_safe()

func _on_drill_finished():
	open_safe()

func open_safe():
	if (name.find("up") != -1):
		$AnimationPlayer.play("Open_up")
	elif (name.find("down") != -1):
		$AnimationPlayer.play("Open_down")
	elif (name.find("left") != -1):
		$AnimationPlayer.play("Open_left")
	elif (name.find("right") != -1):
		$AnimationPlayer.play("Open_right")
	
	$Interaction_hitbox.queue_free()
	$Drill.queue_free()
	
	print(item_stored)
	if (item_stored != "none"):
		var item = load(Game.scene_objects[item_stored]).instance()
		add_child(item)
		item.scale = Vector2(0.75,0.75)
		item.position = Vector2(0,-16)
	

