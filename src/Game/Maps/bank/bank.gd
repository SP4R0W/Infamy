extends Node2D

onready var game_scene: GameScene = get_parent()

func _ready():
	Game.map = self
	Game.map_objects = $Objects
