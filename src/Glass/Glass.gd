extends StaticBody2D


func _ready():
	$AnimatedSprite.animation = "normal"
	set_collision_layer_bit(12,true)
	
func destroy():
	$AnimatedSprite.animation = "broken"
	set_collision_layer_bit(12,false)
