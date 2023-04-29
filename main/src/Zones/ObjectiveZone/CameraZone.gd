extends Area2D

signal objective_entered(object)

# This is used in the tutorial

func _on_ObjectiveZone_body_entered(body):
	if (body.is_in_group("Player")):
		emit_signal("objective_entered",self)
		set_deferred("disabled",true)
