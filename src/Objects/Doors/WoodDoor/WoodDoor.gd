extends StaticBody2D

signal object_interaction_started(object,action)
signal object_interaction_aborted(object,action)
signal object_interaction_finished(object,action)

export var disguises_needed = ["employee","guard"]
export var is_broken: bool = false
export var can_interact: bool = true
export var can_be_broken: bool = true

var has_focus: bool = false
var is_player_inside: bool = false

var is_closed: bool = true

var original_rotation: float

var action = "open"

func _ready():
	original_rotation = $Sprite.rotation_degrees

	$Interaction_panel.hide()
	$Interaction_panel/VBoxContainer/Interaction_progress.hide()

	Game.add_exception($Interaction_hitbox)

func show_panel():
	has_focus = true
	$Interaction_panel.show()
	$Interaction_panel/VBoxContainer/Interaction_progress.hide()

func hide_panel():
	has_focus = false
	$Interaction_panel.hide()

func destroy_door():

	is_broken = true
	can_interact = false

	$NPC_open.call_deferred("queue_free")

	if (is_equal_approx(original_rotation,90)):
		$Sprite.rotation_degrees = 0
	elif (is_equal_approx(original_rotation,0)):
		$Sprite.rotation_degrees = 90

	set_collision_layer_bit(12,false)
	Game.remove_exception($Interaction_hitbox)

func _process(delta):
	if (has_focus && can_interact):
		if (Input.is_action_pressed("interact1") && Game.player_can_interact):
			if (!is_player_inside):
				if (!Game.player_is_interacting):
					Game.player_is_interacting = true

					emit_signal("object_interaction_started",self,self.action)

					$Interaction_timer.wait_time = .5
					$Interaction_timer.start()

					$Interaction_panel/VBoxContainer/Interaction_progress.show()
			else:
				Game.ui.update_popup("Can't interact with doors while inside them",2)

				Game.player_can_interact = false
				get_tree().create_timer(1).connect("timeout",Game,"stop_interaction_grace")

				return
		else:
			if (Game.player_is_interacting):
				emit_signal("object_interaction_aborted",self,self.action)

				Game.player_is_interacting = false
				$Interaction_timer.stop()

				$Interaction_panel/VBoxContainer/Interaction_progress.hide()
	else:
		hide_panel()

	if (Game.player_is_interacting && has_focus):
		$Interaction_panel/VBoxContainer/Interaction_progress.value = (($Interaction_timer.wait_time - $Interaction_timer.time_left) / $Interaction_timer.wait_time) * 100

func _on_Interaction_timer_timeout():
	if (Game.player_is_interacting):
		Game.player_is_interacting = false
		$Interaction_panel/VBoxContainer/Interaction_progress.hide()

		Game.player_can_interact = false
		get_tree().create_timer(0.2).connect("timeout",Game,"stop_interaction_grace")

		emit_signal("object_interaction_finished",self,self.action)

		if (is_closed):
			is_closed = false

			$Interaction_panel/VBoxContainer/Action1.text = "Hold [F] to Close"

			if (is_equal_approx(original_rotation,90)):
				$Sprite.rotation_degrees = 0
			elif (is_equal_approx(original_rotation,0)):
				$Sprite.rotation_degrees = 90

			set_collision_layer_bit(12,false)
		else:
			is_closed = true
			$Interaction_panel/VBoxContainer/Action1.text = "Hold [F] to Open"

			$Sprite.rotation_degrees = original_rotation

			set_collision_layer_bit(12,true)


func _on_NPC_open_area_entered(area):
	if (area.is_in_group("hitbox_npc")):
		if (area.is_in_group("cop")):
			destroy_door()
		else:
			var npc = area.get_parent().get_parent()

			if (!npc.is_hostaged && !npc.is_dead && !npc.is_unconscious && is_closed):
				is_closed = false

				if (is_equal_approx(original_rotation,90)):
					$Sprite.rotation_degrees = 0
				elif (is_equal_approx(original_rotation,0)):
					$Sprite.rotation_degrees = 90

				set_collision_layer_bit(12,false)

				$Close.start()


func end_close():
	is_closed = true

	$Sprite.rotation_degrees = original_rotation

	set_collision_layer_bit(12,true)	

func _on_Collision_hitbox_body_entered(body):
	if (body.is_in_group("Player")):
		is_player_inside = true


func _on_Collision_hitbox_body_exited(body):
	if (body.is_in_group("Player")):
		is_player_inside = false


func _on_VisibilityNotifier2D_screen_entered():
	show()


func _on_VisibilityNotifier2D_screen_exited():
	if (!is_broken):
		hide()
