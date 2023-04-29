extends AnimatedSprite

var col_shapes: Dictionary = {
	"4x4": Vector2(140,56),
	"cabrio": Vector2(148,56),
	"mini": Vector2(112,50),
	"pickup": Vector2(160,56),
	"touring": Vector2(148,56)
}

func _ready():
	hide()
	
	var car_name = animation.split("_")[0]
	$Shadow.animation = car_name
	
	var col_shape = RectangleShape2D.new()
	col_shape.extents = col_shapes[car_name]
	$Body/CollisionShape2D.shape = col_shape


func _on_VisibilityNotifier2D_screen_entered():
	show()

func _on_VisibilityNotifier2D_screen_exited():
	hide()
