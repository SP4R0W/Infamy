extends Node

onready var root: Node = get_tree().root.get_node("Main")

onready var scene_paths: Dictionary = {
	"mainmenu":"res://src/Menus/MainMenu/MainMenu.tscn",
	"lobby":"res://src/Menus/Lobby/Lobby.tscn",
	"gamescene":"res://src/Game/GameScene.tscn",
}

onready var weapon_scene_paths: Dictionary = {
	"M9":"res://src/Weapons/M9/M9.tscn",
	"UZI":"res://src/Weapons/UZI/UZI.tscn"
}
