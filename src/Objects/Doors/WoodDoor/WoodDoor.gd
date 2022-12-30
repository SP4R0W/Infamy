extends StaticBody2D

signal object_interacted(object)

export var disguises_needed = ["employee","guard"]

var has_focus: bool = false

var is_closed: bool = true

var original_rotation = rotation_degrees

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
	if (has_focus):
		if (Input.is_action_pressed("interact1") && Game.player_can_interact):
			if (!Game.player_is_interacting):
				Game.player_is_interacting = true
				
				$Interaction_timer.wait_time = 1
				$Interaction_timer.start()
				
				$Interaction_panel/VBoxContainer/Interaction_progress.show()
				
				if (!disguises_needed.has(Game.player_disguise)):
					Game.player_status = Game.player_statuses.SUSPICIOUS
		else:
			if (Game.player_is_interacting):
				Game.player_is_interacting = false
				$Interaction_timer.stop()
				
				$Interaction_panel/VBoxContainer/Interaction_progress.hide()
				
				if (Game.player_disguise != "normal"):
					Game.player_status = Game.player_statuses.DISGUISED
				else:
					Game.player_status = Game.player_statuses.NORMAL
	
	if (Game.player_is_interacting && has_focus):	
		$Interaction_panel/VBoxContainer/Interaction_progress.value = (($Interaction_timer.wait_time - $Interaction_timer.time_left) / $Interaction_timer.wait_time) * 100

func _on_Interaction_timer_timeout():
	if (Game.player_is_interacting):
		Game.player_is_interacting = false
		$Interaction_panel/VBoxContainer/Interaction_progress.hide()
		
		Game.player_can_interact = false
		get_tree().create_timer(0.2).connect("timeout",Game,"stop_interaction_grace")
		
		if (Game.player_disguise != "normal"):
			Game.player_status = Game.player_statuses.DISGUISED
		else:
			Game.player_status = Game.player_statuses.NORMAL
			
		emit_signal("object_interacted",self.name)
		
		if (is_closed):
			is_closed = false
			
			$Interaction_panel/VBoxContainer/Action1.text = "Hold [F] to Close"
			if (original_rotation == 90):
				$Sprite.rotation_degrees = 0
			elif (original_rotation == 0):
				$Sprite.rotation_degrees = 90
				
			$Door_collision.disabled = true
		else:
			$Interaction_panel/VBoxContainer/Action1.text = "Hold [F] to Open"
			
			$Sprite.rotation_degrees = original_rotation
				
			$Door_collision.disabled = false
