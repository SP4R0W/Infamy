extends Sprite

signal object_interaction_finished(object,action)

var has_focus: bool = false
export var can_interact: bool = true

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
				Game.add_player_inventory_item("keys")
				emit_signal("object_interaction_finished",self,"pickup")
				
				queue_free()
				
				Game.player_can_interact = false
				get_tree().create_timer(0.2).connect("timeout",Game,"stop_interaction_grace")
