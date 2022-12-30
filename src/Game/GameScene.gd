extends Node2D
class_name GameScene

var level_paths: Dictionary = {
	"busy":"res://src/Game/Maps/busy/busy.tscn",
	"italy":"res://src/Game/Maps/italy/italy.tscn",
	"bank":"res://src/Game/Maps/bank/bank.tscn"
}

func _ready():
	Game.game_scene = self
	
	Game.game_process = false
	
	load_level()
	
	show_preplanning()

func load_level() -> void:
	var level = load(level_paths[Game.level]).instance()
	add_child(level)

	
func start_game() -> void:
	show_gameui()
	
	Game.game_process = true

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
