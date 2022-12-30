extends ColorRect

signal object_pickup(object)

var has_focus: bool = false

func _ready():
	$Interaction_panel.hide()

func show_panel():
	has_focus = true
	$Interaction_panel.show()
	
func hide_panel():
	has_focus = false
	$Interaction_panel.hide()

func _process(delta):
	if (has_focus):
		if (Input.is_action_pressed("interact1") && Game.player_can_interact):
			if (!Game.player_is_interacting):
				if (Game.player_disguise != "guard"):
					Game.change_player_disguise("guard")
					emit_signal("object_pickup",self.name)
					
					queue_free()
					
				Game.player_can_interact = false
				get_tree().create_timer(0.2).connect("timeout",Game,"stop_interaction_grace")
