extends Sprite

signal object_interaction_started(object,action)
signal object_interaction_aborted(object,action)
signal object_interaction_finished(object,action)

export var disguises_needed = []

export var can_interact: bool = true

var has_focus: bool = false
var is_hacking: bool = false

var action = "hack"

func _ready():
	$Interaction_panel.hide()
	$Hacking_panel.hide()
	$Interaction_panel/VBoxContainer/Interaction_progress.hide()
	$Interaction_panel/VBoxContainer/Action1.text = "Hold [F] to Hack"
	
func show_panel():
	has_focus = true
	$Interaction_panel.show()
	$Interaction_panel/VBoxContainer/Interaction_progress.hide()
	
func hide_panel():
	has_focus = false
	$Interaction_panel.hide()

func _process(delta):
	if (has_focus && can_interact):
		if (Input.is_action_pressed("interact1") && Game.player_can_interact):
			if (!Game.player_is_interacting):
				Game.player_is_interacting = true
				
				emit_signal("object_interaction_started",self,self.action)
				
				if (action == "hack"):
					$Interaction_timer.wait_time = 3.5
					$keyboard.play()
				elif (action == "code"):
					$Interaction_timer.wait_time = 0.1
					
				$Interaction_timer.start()
				
				$Interaction_panel/VBoxContainer/Interaction_progress.show()
				
				Game.suspicious_interaction = true
		else:
			if (Game.player_is_interacting):
				emit_signal("object_interaction_aborted",self,self.action)
				
				$keyboard.stop()
				
				Game.player_is_interacting = false
				$Interaction_timer.stop()
				
				$Interaction_panel/VBoxContainer/Interaction_progress.hide()
				
				Game.suspicious_interaction = false
	else:
		hide_panel()
	
	if (Game.player_is_interacting && has_focus):	
		$Interaction_panel/VBoxContainer/Interaction_progress.value = (($Interaction_timer.wait_time - $Interaction_timer.time_left) / $Interaction_timer.wait_time) * 100
	elif (is_hacking):
		$Hacking_panel/VBoxContainer/Interaction_progress.value = (($Hack_timer.wait_time - $Hack_timer.time_left) / $Hack_timer.wait_time) * 100

func _on_Interaction_timer_timeout():
	if (Game.player_is_interacting):
		
		can_interact = false
		Game.player_is_interacting = false
		
		$Interaction_panel/VBoxContainer/Interaction_progress.hide()
		$Hacking_panel.hide()
		
		$keyboard.stop()
		
		Game.player_can_interact = false
		get_tree().create_timer(0.2).connect("timeout",Game,"stop_interaction_grace")
		
		Game.suspicious_interaction = false
			
		emit_signal("object_interaction_finished",self,self.action)
		
		if (action == "hack"):
			start_hack()
		elif (action == "code"):
			Game.add_player_inventory_item("vault_code")
		
func start_hack():
	$Interaction_panel.hide()
	$Hacking_panel.show()
	$Hack_timer.start()
	$Hacking_panel/VBoxContainer/Action/AnimationPlayer.play("Hacking")
	is_hacking = true

func _on_Hack_timer_timeout():
	$Hacking_panel/VBoxContainer/Action/AnimationPlayer.stop()
	$Hacking_panel/VBoxContainer/Action.text = "Hacking: DONE!"
	$Interaction_panel/VBoxContainer/Action1.text = "Hold [F] to get Vault Code"
	can_interact = true
	action = "code"


func _on_VisibilityNotifier2D_screen_entered():
	set_process(true)
	show()


func _on_VisibilityNotifier2D_screen_exited():
	set_process(false)	
	hide()
