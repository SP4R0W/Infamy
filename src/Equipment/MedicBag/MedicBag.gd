extends Sprite

signal object_interaction_started(object,action)
signal object_interaction_aborted(object,action)
signal object_interaction_finished(object,action)

export var can_interact: bool = true

export var max_uses: int = 2
export var remaining_uses: int = 2

var has_focus: bool = false
var has_medic: bool = Game.has_item_in_equipment("Medic Bag")

var action: String

func _ready():
	$Interaction_panel/VBoxContainer/Uses.text = "Uses left: " + str(remaining_uses) + "/" + str(max_uses)
	
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
	if (has_focus && can_interact):
		if (Input.is_action_pressed("interact1") && Game.player_can_interact):
			if (!Game.player_is_interacting):
				Game.player_is_interacting = true
				action = "use"
				
				emit_signal("object_interaction_started",self,self.action)
				
				$Interaction_timer.wait_time = 3
					
				$Interaction_timer.start()
				
				$Interaction_panel/VBoxContainer/Interaction_progress.show()
			
		elif (Input.is_action_pressed("interact2") && Game.player_can_interact && has_medic):
			if (!Game.player_is_interacting):
				for item in Game.player_equipment:
					if (item.has("medic")):
						if (item[1] >= Game.max_equipment_amounts["medic"]):
							Game.ui.update_popup("You can't carry more first aid kits!",2)
							
							Game.player_can_interact = false
							get_tree().create_timer(1).connect("timeout",Game,"stop_interaction_grace")
							
							return
				
				Game.player_is_interacting = true
				action = "take"
				
				emit_signal("object_interaction_started",self,self.action)
				
				$Interaction_timer.wait_time = 1
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
		
		if (action == "use"):
			Game.ui.do_green_effect()
			remaining_uses -= 1
		elif (action == "take"):
			for item in Game.player_equipment:
				if (item.has("medic")):
					var needed = Game.max_equipment_amounts["medic"] - item[1]
					if (remaining_uses >= needed):
						remaining_uses -= needed
						item[1] += needed
					else:
						item[1] += remaining_uses
						remaining_uses = 0
			
		$Interaction_panel/VBoxContainer/Uses.text = "Uses left: " + str(remaining_uses) + "/" + str(max_uses)
		
		if (remaining_uses == 0):
			queue_free()


func _on_VisibilityNotifier2D_screen_entered():
	if (name in Game.map_assets):
		set_process(true)
		show()


func _on_VisibilityNotifier2D_screen_exited():
	set_process(false)	
	hide()
