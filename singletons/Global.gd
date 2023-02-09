extends Node

onready var root: Node = get_tree().root.get_node("Main")

onready var scene_paths: Dictionary = {
	"mainmenu":"res://src/Menus/MainMenu/MainMenu.tscn",
	"inventory":"res://src/Menus/Inventory/Inventory.tscn",	
	"help":"res://src/Menus/Help/Help.tscn",
	"credits":"res://src/Menus/Credits/Credits.tscn",
	"lobby":"res://src/Menus/Lobby/Lobby.tscn",
	"tutorial":"res://src/Menus/Lobby/Lobby.tscn",
	"gamescene":"res://src/Game/GameScene.tscn",
}

onready var weapon_scene_paths: Dictionary = {
	"M9":"res://src/Weapons/M9/M9.tscn",
	"UZI":"res://src/Weapons/UZI/UZI.tscn"
}

onready var item_previews: Dictionary = {
	"M9":"res://src/Menus/Inventory/assets/m9_preview.png",
	"UZI":"res://src/Menus/Inventory/assets/uzi_preview.png",
	
	"Suit":"res://src/Menus/Inventory/assets/suit_preview.png",

	"Medic Bag":"res://src/Menus/Inventory/assets/medic_preview.png",
	"Ammo Bag":"res://src/Menus/Inventory/assets/ammo_preview.png",
	"ECM":"res://src/Menus/Inventory/assets/ecm_preview.png",
	"C4":"res://src/Menus/Inventory/assets/c4_preview.png",
}

onready var music_paths: Dictionary = {
	"Velocity":{
		"stealth":"res://assets/music/Velocity/stealth.ogg",
		"loud":"res://assets/music/Velocity/loud.ogg"
	},
	"Assault":{
		"stealth":"res://assets/music/Assault/stealth.ogg",
		"loud":"res://assets/music/Assault/loud.ogg"
	}
}
