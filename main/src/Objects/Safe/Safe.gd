extends StaticBody2D

signal object_interaction_started(object,action)
signal object_interaction_aborted(object,action)
signal object_interaction_finished(object,action)

export var disguises_needed = []

var has_focus: bool = false

export var can_interact: bool = true
export var item_stored: String = "none"

var beep_counter = 0
var max_beeps = 4

var action: String

func _ready():
	if (name.find("up") != -1):
		$Door.rotation_degrees = 0
	elif (name.find("down") != -1):
		$Door.rotation_degrees = 180
	elif (name.find("left") != -1):
		$Door.rotation_degrees = -90
	elif (name.find("right") != -1):
		$Door.rotation_degrees = 90

	$Drill.hide()
	$C4.hide()

	$Interaction_panel.hide()
	$Interaction_panel/VBoxContainer/Interaction_progress.hide()

func show_panel():
	has_focus = true
	$Interaction_panel.show()
	$Interaction_panel/VBoxContainer/Interaction_progress.hide()

func hide_panel():
	has_focus = false
	$Interaction_panel.hide()

func _process(delta):
	if (Game.player_inventory.has("safe_code")):
		$Interaction_panel/VBoxContainer/Action2.text = "Hold [X] to Open"
	else:
		$Interaction_panel/VBoxContainer/Action2.text = "Hold [X] to Lockpick"

	if (has_focus && can_interact):
		if (Input.is_action_pressed("interact1") && Game.player_can_interact):
			if (!Game.player_is_interacting):
				Game.player_is_interacting = true
				action = "drill"

				emit_signal("object_interaction_started",self,self.action)

				$Interaction_timer.wait_time = 3
				Game.suspicious_interaction = true

				$Interaction_timer.start()

				$Interaction_panel/VBoxContainer/Interaction_progress.show()

		elif (Input.is_action_pressed("interact2") && Game.player_can_interact):
			if (!Game.player_is_interacting):
				if (Game.get_skill("infiltrator",4,2) != "upgraded" && !Game.player_inventory.has("safe_code")):
					Game.ui.update_popup("You need the upgraded 'Locksmith' Skill!",2)

					Game.player_can_interact = false
					get_tree().create_timer(1).connect("timeout",Game,"stop_interaction_grace")

					return

				Game.player_is_interacting = true
				action = "lockpick"

				$Lockpick.play()

				emit_signal("object_interaction_started",self,self.action)

				if (!Game.player_inventory.has("safe_code")):
					$Interaction_timer.wait_time = 10
				else:
					$Interaction_timer.wait_time = 3

				$Interaction_timer.start()

				$Interaction_panel/VBoxContainer/Interaction_progress.show()

				Game.suspicious_interaction = true
		elif (Input.is_action_pressed("interact3") && Game.player_can_interact):
			if (!Game.player_is_interacting):
				if (Game.get_skill("engineer",3,2) != "upgraded"):
					Game.ui.update_popup("You need the upgraded 'Breacher' Skill!",2)

					Game.player_can_interact = false
					get_tree().create_timer(1).connect("timeout",Game,"stop_interaction_grace")

					return

				if (!Game.get_amount_of_equipment("C4") > 0):
					Game.ui.update_popup("You have no C4 remaining!",2)

					Game.player_can_interact = false
					get_tree().create_timer(1).connect("timeout",Game,"stop_interaction_grace")

					return


				Game.player_is_interacting = true
				action = "c4"

				emit_signal("object_interaction_started",self,self.action)

				$Interaction_timer.wait_time = 2
				$Interaction_timer.start()

				$Interaction_panel/VBoxContainer/Interaction_progress.show()

				Game.suspicious_interaction = true
		else:
			if (Game.player_is_interacting):
				emit_signal("object_interaction_aborted",self,self.action)

				$Lockpick.stop()

				Game.player_is_interacting = false
				$Interaction_timer.stop()

				$Interaction_panel/VBoxContainer/Interaction_progress.hide()

				Game.suspicious_interaction = false
	else:
		$Lockpick.stop()
		hide_panel()

	if (Game.player_is_interacting && has_focus):
		$Interaction_panel/VBoxContainer/Interaction_progress.value = (($Interaction_timer.wait_time - $Interaction_timer.time_left) / $Interaction_timer.wait_time) * 100

func _on_Interaction_timer_timeout():
	if (Game.player_is_interacting):
		can_interact = false
		Game.player_is_interacting = false
		$Interaction_panel/VBoxContainer/Interaction_progress.hide()
		$Interaction_hitbox/CollisionShape2D.disabled = true

		Game.player_can_interact = false
		get_tree().create_timer(0.2).connect("timeout",Game,"stop_interaction_grace")

		Game.suspicious_interaction = false

		$Lockpick.stop()

		emit_signal("object_interaction_finished",self,self.action)

		if (action == "drill"):
			$Drill.show()
			$Drill.start_drill()
		elif (action == "lockpick"):
			open_safe()
		elif (action == "c4"):
			Game.use_player_equipment("C4")

			$C4.show()
			$C4_noise.play()
			$C4_timer.start()


func _on_C4_timer_timeout():
	beep_counter += 1

	if (beep_counter < max_beeps):
		$C4_noise.play()
		$C4_timer.start()
	else:
		$C4.hide()
		$Explosion.play()

		var noise = Game.scene_objects["alert"].instance()
		noise.type = "c4_object"
		noise.radius = 4000
		noise.time = 0.1
		call_deferred("add_child",noise)

		noise.start()

		open_safe()

func _on_drill_finished():
	open_safe()

func open_safe():
	if (name.find("up") != -1):
		$AnimationPlayer.play("Open_up")
	elif (name.find("down") != -1):
		$AnimationPlayer.play("Open_down")
	elif (name.find("left") != -1):
		$AnimationPlayer.play("Open_left")
	elif (name.find("right") != -1):
		$AnimationPlayer.play("Open_right")

	$Interaction_hitbox.queue_free()
	$Drill.queue_free()

	if (item_stored != "none"):
		var item = Game.scene_objects[item_stored].instance()
		add_child(item)
		item.scale = Vector2(0.75,0.75)
		item.position = Vector2(0,-16)

