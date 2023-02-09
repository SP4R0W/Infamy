extends VBoxContainer

var music_info: Dictionary = {
	"bank":1
}

var music_tracks: Array = [
	"Velocity",
	"Assault"
]

var selected_track = music_info[Game.level]

func _ready():
	yield(get_tree().create_timer(0.5),"timeout")
	
	load_track()
	
func load_track():
	Game.game_scene.get_node("Audio/stealth").stop()
	Game.game_scene.get_node("Audio/loud").stop()
	
	$HBoxContainer2/stealth.text = "Stealth Preview"
	$HBoxContainer2/loud.text = "Loud Preview"
	
	var briefing = Game.game_scene.get_node("Audio/briefing")
	if (!briefing.playing):
		briefing.play()
	
	$HBoxContainer/Title.text = music_tracks[selected_track]	
	
	var track = music_tracks[selected_track]
	
	var stealth: AudioStreamPlayer = Game.game_scene.get_node("Audio/stealth")
	var loud: AudioStreamPlayer = Game.game_scene.get_node("Audio/loud")
	
	stealth.stream = load(Global.music_paths[track]["stealth"])
	loud.stream = load(Global.music_paths[track]["loud"])


func _on_prev_pressed():
	selected_track -= 1
	if (selected_track < 0):
		selected_track = music_tracks.size() - 1
		
	load_track()


func _on_next_pressed():
	selected_track += 1
	if (selected_track >= music_tracks.size()):
		selected_track = 0
		
	load_track()


func _on_stealth_pressed():
	var stealth: AudioStreamPlayer = Game.game_scene.get_node("Audio/stealth")

	if (stealth.playing):
		$HBoxContainer2/stealth.text = "Stealth Preview"
		Game.game_scene.get_node("Audio/briefing").play()
		stealth.stop()
	else:
		$HBoxContainer2/stealth.text = "Stop Preview"
		$HBoxContainer2/loud.text = "Loud Preview"
		Game.game_scene.get_node("Audio/briefing").stop()
		stealth.play()
		Game.game_scene.get_node("Audio/loud").stop()


func _on_loud_pressed():
	var loud: AudioStreamPlayer = Game.game_scene.get_node("Audio/loud")
	
	if (loud.playing):
		$HBoxContainer2/loud.text = "Loud Preview"
		Game.game_scene.get_node("Audio/briefing").play()
		loud.stop()
	else:
		$HBoxContainer2/stealth.text = "Stealth Preview"
		$HBoxContainer2/loud.text = "Stop Preview"
		Game.game_scene.get_node("Audio/briefing").stop()
		loud.play()
		Game.game_scene.get_node("Audio/stealth").stop()
