extends Node2D

var noise_scene = preload("res://src/Zones/AlertZone/AlertZone.tscn")

signal object_interaction_started(object,action)
signal object_interaction_aborted(object,action)
signal object_interaction_finished(object,action)

signal drill_finished()

export var disguises_needed = []

export var can_interact: bool = false
export var drill_duration: int = 30

var has_focus: bool = false
var is_drilling: bool = false

var action = "repair"

var possible_jams = [[15,89,-1],[45,64,-1],[10,43,-1],[73,90,-1],[33,-1],[87,-1],[64,-1],[95,-1]]
var jams = 0
var jam_method

var noise_area

func _ready():
	hide()
	jam_method = possible_jams[randi() % (possible_jams.size() - 1)]
	
	$Interaction_panel.hide()
	$Drill_panel.hide()
	$Interaction_panel/VBoxContainer/Interaction_progress.hide()
	
	noise_area = noise_scene.instance()
	noise_area.radius = 500
	noise_area.time = -1
	add_child(noise_area)

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
				
				$Interaction_timer.wait_time = 2
					
				$Interaction_timer.start()
				
				$Interaction_panel/VBoxContainer/Interaction_progress.show()
				
				Game.suspicious_interaction = true
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
	elif (is_drilling):
		$Drill_panel/VBoxContainer/Action.text = "Drilling... " + str(round($Drill_timer.time_left)) + "s left"
		
		var drill_value = (($Drill_timer.wait_time - $Drill_timer.time_left) / $Drill_timer.wait_time) * 100
		if (round(drill_value) == jam_method[jams]):
			jam_drill()

func _on_Interaction_timer_timeout():
	if (Game.player_is_interacting):
		
		can_interact = false
		Game.player_is_interacting = false
		
		$Interaction_panel/VBoxContainer/Interaction_progress.hide()
		
		Game.player_can_interact = false
		get_tree().create_timer(0.2).connect("timeout",Game,"stop_interaction_grace")
		
		Game.suspicious_interaction = false
			
		emit_signal("object_interaction_finished",self,self.action)
		
		resume_drill()
		
func start_drill():
	show()
	can_interact = false
	$Interaction_panel.hide()
	$Drill_panel.show()
	$Drill_timer.wait_time = drill_duration
	$Drill_timer.start()

	is_drilling = true
	
	noise_area.unpause()
	
func jam_drill():
	can_interact = true
	is_drilling = false
	
	$Drill_panel/VBoxContainer/Action.text = "Drilling... JAMMED"
	$Drill_timer.paused = true

	jams += 1
	
	noise_area.pause()
	
	
func resume_drill():
	can_interact = false
	$Interaction_panel.hide()
	$Drill_panel.show()
	$Drill_timer.paused = false

	is_drilling = true
	
	noise_area.unpause()	

func _on_Drill_timer_timeout():
	noise_area.remove()
	
	emit_signal("drill_finished")
	
	queue_free()
