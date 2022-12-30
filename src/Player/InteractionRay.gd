extends RayCast2D

var current_object_interact = null
var current_object = null

func _ready():
	pass
	
func _physics_process(delta):
	if (is_colliding()):
		var node = get_collider()
		if (node.is_in_group("interactable")):
			if (current_object == null):
				current_object_interact = node
				current_object = node.get_parent()
				current_object.show_panel()
	else:
		if (current_object != null):
			for items in get_tree().get_nodes_in_group("interactable"):
				if (items == current_object_interact):
					current_object.hide_panel()
					current_object = null
					current_object_interact = null
					return
			
			current_object = null
			current_object_interact = null
