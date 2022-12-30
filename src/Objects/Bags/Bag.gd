extends AnimatedSprite

signal object_pickup(object)

export var disguises_needed = []
export var bag_type: String = "" setget bag_name_set
export var has_disguise: bool = false

var action: String = "none"

var has_focus: bool = false

func bag_name_set(new_value) -> void:
	bag_type = new_value
	$Interaction_panel/VBoxContainer/Title.text = bag_type.capitalize()

func _ready():
	$Interaction_panel/VBoxContainer/Title.text = bag_type.capitalize()

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
	if (has_disguise):
		$Interaction_panel/VBoxContainer/Action2.show()
	else:
		$Interaction_panel/VBoxContainer/Action2.hide()
	
	if (has_focus):
		if (Input.is_action_pressed("interact1") && Game.player_can_interact && Game.player_bag == "empty"):
			if (!Game.player_is_interacting):
				Game.player_is_interacting = true
				action = "carry"
				
				$Interaction_timer.wait_time = 0.5
				$Interaction_timer.start()
				
				$Interaction_panel/VBoxContainer/Interaction_progress.show()
				
				if (!disguises_needed.has(Game.player_disguise)):
					Game.player_status = Game.player_statuses.SUSPICIOUS
		elif (Input.is_action_pressed("interact2") && Game.player_can_interact && has_disguise && Game.player_disguise != bag_type):
			if (!Game.player_is_interacting):
				Game.player_is_interacting = true
				action = "disguise"
				
				$Interaction_timer.wait_time = 5
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
			
		emit_signal("object_pickup",self.name)
		
		if (action == "carry"):
			Game.carry_bag(self.bag_type,self.has_disguise)
			queue_free()
		elif (action == "disguise"):
			has_disguise = false
			Game.change_player_disguise(self.bag_type)
