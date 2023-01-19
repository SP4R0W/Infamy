extends StaticBody2D

var is_broken: bool = false

func _ready():
	hide()
	
	$AnimatedSprite.animation = "normal"
	set_collision_layer_bit(12,true)
	
	get_tree().call_group("Detection","add_exception",self)
	
func destroy():
	is_broken = true
	
	$AnimatedSprite.animation = "broken"
	set_collision_layer_bit(12,false)
	
	get_tree().call_group("Detection","remove_exception",self)
	


func _on_VisibilityNotifier2D_screen_entered():
	show()

func _on_VisibilityNotifier2D_screen_exited():
	hide()
