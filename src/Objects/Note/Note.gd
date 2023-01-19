extends Sprite

signal object_interaction_started(object,action)
signal object_interaction_aborted(object,action)
signal object_interaction_finished(object,action)

export var disguises_needed = ["employee"]

export var can_interact: bool = true
export var has_phone_number: bool = false

var has_focus: bool = false

var action = "search"

func _ready():
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
				
				emit_signal("object_interaction_started",self.name,self.action)
				
				$Interaction_timer.wait_time = 0.5
				$Interaction_timer.start()
				
				$Interaction_panel/VBoxContainer/Interaction_progress.show()
				
				if (!disguises_needed.has(Game.player_disguise)):
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
		
		if (has_phone_number):
			Game.add_player_inventory_item("p_number")
		
		queue_free()
