extends Node2D
class_name GameScene

var level_paths: Dictionary = {
	"busy":"res://src/Game/Maps/busy/busy.tscn",
	"italy":"res://src/Game/Maps/italy/italy.tscn",
	"bank":"res://src/Game/Maps/bank/bank.tscn"
}

func _ready():
	$Audio/briefing.play()
	
	Game.game_scene = self
	
	restart_game()
	
	load_level()
	
	show_preplanning()

func restart_game():
	Game.map_assets = []
	
	Game.player_current_equipment = 0
	Game.player_inventory = []
	
	Game.is_game_loud = false
	Game.player_weapon = -1
	Game.player_disguise = "normal"
	Game.player_status = Game.player_statuses.NORMAL

	Game.player_bag = "empty"
	Game.player_bag_has_disguise = false

	Game.player_can_move = true
	Game.player_can_interact = true
	Game.player_can_shoot= true
	Game.player_can_melee = true
	Game.player_can_run = true

	Game.player_is_interacting= false
	Game.suspicious_interaction = false
	Game.player_is_reloading = false
	Game.player_is_meleing = false
	Game.player_is_running = false

	Game.player_collision_zones = []

	Game.game_process = false
	
	Game.hostages = 0
	Game.kills = 0
	
	Game.handcuffs = Game.max_handcuffs
	Game.bodybags = Game.max_bodybags

func load_level() -> void:
	var level = load(level_paths[Game.level]).instance()
	add_child(level)
	
	Game.game_scene_map_path = level_paths[Game.level]
	
func start_game() -> void:
	$Audio/briefing.stop()	
	
	show_gameui()
	
	Game.game_process = true
	Game.map.update_objective(1)
	Game.map.set_assets()
	
	$Audio/stealth.play()

func _on_Start_btn_pressed() -> void:
	start_game()

func _on_Menu_btn_pressed() -> void:
	Composer.goto_scene(Global.scene_paths["lobby"],true,true,0.5,0.5)

func show_preplanning() -> void:
	$Control/CanvasLayer/Preplanning.show()
	$Control/CanvasLayer/GameUI.hide()
	$Control/CanvasLayer/Heist_success.hide()
	$Control/CanvasLayer/Heist_fail.hide()
	
	$Control/CanvasLayer/Start_btn.show()
	$Control/CanvasLayer/Menu_btn.show()
	
func show_gameui() -> void:
	$Control/CanvasLayer/Preplanning.hide()
	$Control/CanvasLayer/GameUI.show()
	$Control/CanvasLayer/Heist_success.hide()
	$Control/CanvasLayer/Heist_fail.hide()
	
	$Control/CanvasLayer/Start_btn.hide()
	$Control/CanvasLayer/Menu_btn.hide()
	
func show_gamewin() -> void:
	$Control/CanvasLayer/Preplanning.hide()
	$Control/CanvasLayer/GameUI.hide()
	$Control/CanvasLayer/Heist_success.show()
	$Control/CanvasLayer/Heist_fail.hide()
	
	$Control/CanvasLayer/Start_btn.hide()
	$Control/CanvasLayer/Menu_btn.show()
	
	Game.game_process = false
	
func show_gamefail() -> void:
	$Control/CanvasLayer/Preplanning.hide()
	$Control/CanvasLayer/GameUI.hide()
	$Control/CanvasLayer/Heist_success.hide()
	$Control/CanvasLayer/Heist_fail.show()
	
	$Control/CanvasLayer/Start_btn.hide()
	$Control/CanvasLayer/Menu_btn.show()
	
	Game.game_process = false

func _exit_tree():
	Game.game_scene = null
