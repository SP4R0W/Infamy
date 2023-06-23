extends NPC

export var is_static: bool = true

var velocity: Vector2 = Vector2.ZERO

var cur_pos: int = 0

var weapon_mag = 0

func on_ready():
	$AnimatedSprite.animation = "stand"

	yield(get_tree().create_timer(0.5),"timeout")

	.on_ready()

func take_damage(damage: float,type: String = "none"):
	pass

func set_npc_interactions():
	has_second_interaction = false
	has_third_interaction = false

	if (is_unconscious):
		$Interaction_panel/VBoxContainer/Action1.text = "Hold [F] to Take Disguise"
		$Interaction_panel/VBoxContainer/Action2.hide()
		$Interaction_panel/VBoxContainer/Action3.hide()
	else:
		if (!was_interrogated):
			$Interaction_panel/VBoxContainer/Action1.text = "Hold [F] to Interrogate"

		if is_hostaged && was_interrogated:
			$Interaction_panel/VBoxContainer/Action3.show()
			$Interaction_panel/VBoxContainer/Action3.text = "Press [V] to Knock out the Guard"
		elif is_hostaged && !was_interrogated:
			$Interaction_panel/VBoxContainer/Action3.hide()
			$Interaction_panel/VBoxContainer/Action3.text = "Approach with a gun to hostage"
		else:
			$Interaction_panel/VBoxContainer/Action3.show()
			$Interaction_panel/VBoxContainer/Action3.text = "Approach with a gun to hostage"

	.set_npc_interactions()

func check_interactions():
	if (has_focus && can_interact):
		$Interaction_panel/VBoxContainer/Action1.show()

		if (Input.is_action_pressed("interact1") && Game.player_can_interact):
			if (!Game.player_is_interacting):
				if is_unconscious:
					action = "disguise"
					$Interaction_timer.wait_time = 7.5
				else:
					action = "interrogate"
					$Interaction_timer.wait_time = 4

				Game.player_is_interacting = true
				$Interaction_timer.start()

				$Interaction_panel/VBoxContainer/Interaction_progress.show()

				Game.suspicious_interaction = true

				emit_signal("object_interaction_started",self,self.action)
		else:
			if (Game.player_is_interacting):

				Game.player_is_interacting = false
				$Interaction_timer.stop()

				$Interaction_panel/VBoxContainer/Interaction_progress.hide()

				Game.suspicious_interaction = false

				emit_signal("object_interaction_aborted",self,self.action)
	elif (has_focus && !can_interact):
		$Interaction_panel/VBoxContainer/Action1.hide()
	else:
		hide_panel()

	if (Game.player_is_interacting && has_focus):
		$Interaction_panel/VBoxContainer/Interaction_progress.value = (($Interaction_timer.wait_time - $Interaction_timer.time_left) / $Interaction_timer.wait_time) * 100

	.check_interactions()

func finish_interactions():
	if (Game.player_is_interacting):
		Game.player_is_interacting = false
		$Interaction_panel/VBoxContainer/Interaction_progress.hide()

		Game.player_can_interact = false
		get_tree().create_timer(0.2).connect("timeout",Game,"stop_interaction_grace")

		Game.suspicious_interaction = false

		emit_signal("object_interaction_finished",self,self.action)

		if (action == "disguise"):
			Game.change_player_disguise("guard")
			has_disguise = false
		elif (action == "interrogate"):
			was_interrogated = true
			Game.map.interrogated(info)

	.finish_interactions()

func alerted():
	$AnimatedSprite.animation = "shoot"

	.alerted()

func knockout():
	if (!is_unconscious && !is_dead && can_knock):
		$AnimatedSprite.animation = "knocked"

		.knockout()

func hostage():
	is_hostaged = true
	$AnimatedSprite.animation = "untied"

	.hostage()
