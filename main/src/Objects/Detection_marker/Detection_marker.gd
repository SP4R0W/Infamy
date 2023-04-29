extends Node2D

func set_marker_position(bounds: Rect2):
	$AnimatedSprite.global_position = Vector2(
		clamp(global_position.x,bounds.position.x + 15,bounds.end.x - 15),
		clamp(global_position.y,bounds.position.y + 20,bounds.end.y - 20)
	)

func _process(delta):
	var canvas = get_canvas_transform()
	var top_left = -canvas.get_origin() / canvas.get_scale();
	var size = get_viewport_rect().size / canvas.get_scale()
	set_marker_position(Rect2(top_left,size))
