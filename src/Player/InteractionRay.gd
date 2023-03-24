extends RayCast2D

var current_object_interact = null
var current_object = null

func _ready():
	pass
	
func _physics_process(delta):
	if (is_colliding()):
		var node = get_collider()
		if (current_object == null):	
			if (node.is_in_group("interactable")):
				if (node.is_in_group("npc") && node.get_parent().visible):
					current_object_interact = node
					current_object = node.get_parent()
					current_object.show_panel()
				else:
					if (node.get_parent().can_interact && node.get_parent().visible):
						current_object_interact = node
						current_object = node.get_parent()
						current_object.show_panel()
						current_object.z_index = 5
		else:
			if (current_object != node.get_parent()):
				if (get_tree().get_nodes_in_group("interactable").has(current_object_interact)):
					current_object.hide_panel()
					
					var timer = current_object.get_node_or_null("Interaction_timer")
					if (timer != null):
						timer.stop()
					
					Game.player_is_interacting = false
				
				if (is_instance_valid(current_object)):
					current_object.z_index = 1
					
				current_object = null
				current_object_interact = null
	else:
		if (current_object != null):
			if (get_tree().get_nodes_in_group("interactable").has(current_object_interact)):
				current_object.hide_panel()
				var timer = current_object.get_node_or_null("Interaction_timer")
				if (timer != null):
					timer.stop()
					
				Game.player_is_interacting = false
				
				if (is_instance_valid(current_object)):
					current_object.z_index = 1
					
				current_object = null
				current_object_interact = null
			else:
				Game.player_is_interacting = false
				
				current_object = null
				current_object_interact = null
				
