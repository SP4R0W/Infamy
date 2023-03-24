extends Sprite

signal object_interaction_started(object,action)
signal object_interaction_aborted(object,action)
signal object_interaction_finished(object,action)

export var can_interact: bool = true

export var max_uses: int = 12
export var remaining_uses: int = 12

var has_focus: bool = false

var action: String

func _ready():
	$Interaction_panel/VBoxContainer/Uses.text = "Ties left: " + str(remaining_uses) + "/" + str(max_uses)

	$Interaction_panel.hide()
	$Interaction_panel/VBoxContainer/Interaction_progress.hide()

func show_panel():
	has_focus = true
	$Interaction_panel.show()
	$Interaction_panel/VBoxContainer/Interaction_progress.hide()

func hide_panel():
	has_focus = false
	$Interaction_panel.hide()
	
func cable_guy_skill():
	remaining_uses = 24
	max_uses = 24
	$Interaction_panel/VBoxContainer/Uses.text = "Ties left: " + str(remaining_uses) + "/" + str(max_uses)

func _process(delta):
	if (has_focus && can_interact):
		if (Input.is_action_pressed("interact1") && Game.player_can_interact):
			if (!Game.player_is_interacting):
				if (Game.handcuffs >= Game.max_handcuffs):
					Game.ui.update_popup("You can't carry more handcuffs!",2)

					Game.player_can_interact = false
					get_tree().create_timer(1).connect("timeout",Game,"stop_interaction_grace")
					return

				Game.player_is_interacting = true
				action = "use"

				emit_signal("object_interaction_started",self,self.action)

				$Interaction_timer.wait_time = 2

				$Interaction_timer.start()

				$Interaction_panel/VBoxContainer/Interaction_progress.show()
		else:
			if (Game.player_is_interacting):
				emit_signal("object_interaction_aborted",self,self.action)

				Game.player_is_interacting = false
				$Interaction_timer.stop()

				$Interaction_panel/VBoxContainer/Interaction_progress.hide()

				Game.suspicious_interaction = false
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

		Game.suspicious_interaction = false

		emit_signal("object_interaction_finished",self,self.action)

		var needed = Game.max_handcuffs - Game.handcuffs
		if (remaining_uses >= needed):
			remaining_uses -= needed
			Game.handcuffs += needed
		else:
			Game.handcuffs += remaining_uses
			remaining_uses = 0

		$Interaction_panel/VBoxContainer/Uses.text = "Ties left: " + str(remaining_uses) + "/" + str(max_uses)

		if (remaining_uses == 0):
			queue_free()


func _on_VisibilityNotifier2D_screen_entered():
	if (name in Game.map_assets):
		set_process(true)
		show()


func _on_VisibilityNotifier2D_screen_exited():
	set_process(false)
	hide()
