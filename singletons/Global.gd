extends Node

onready var is_HTML: bool = false
onready var music_skip: float = 0

onready var root: Node = get_tree().root.get_node("Main")

onready var scene_paths: Dictionary = {
	"mainmenu":"res://src/Menus/MainMenu/MainMenu.tscn",
	"inventory":"res://src/Menus/Inventory/Inventory.tscn",	
	"settings":"res://src/Menus/Settings/Settings.tscn",
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

onready var weapon_attachment_paths: Dictionary = {
	"suppressor1":"res://src/Weapons/assets/suppressor1.png",
	"suppressor2":"res://src/Weapons/assets/suppressor2.png",
	"suppressor3":"res://src/Weapons/assets/suppressor3.png",
	"compensator1":"res://src/Weapons/assets/compensator1.png",
	"compensator2":"res://src/Weapons/assets/compensator2.png",
	"compensator3":"res://src/Weapons/assets/compensator3.png",
	"stock_uzi":"res://src/Weapons/assets/stock_uzi.png"
}

onready var weapon_base_values: Dictionary = {
	"M9":{
		"reload_time":1,
		"reload_time_empty":1.5,
		"firerate":100,
		"magsize":8,
		"ammo_count":80,
		"damage":10,
		"accuracy":60,
		"concealment":9,
		"price":10000,
	},
	"UZI":{
		"reload_time":1,
		"reload_time_empty":1.5,
		"firerate":800,
		"magsize":30,
		"ammo_count":210,
		"damage":10,
		"accuracy":20,
		"concealment":8,
		"price":10000,
	},
}

onready var weapon_attachment_names: Dictionary = {
	"suppressor1":"Medium Suppressor",
	"suppressor2":"Cheap Suppressor",
	"suppressor3":"Hitman Suppressor",
	"compensator1":"Regular Compensator",
	"compensator2":"Punchy Compensator",
	"compensator3":"Big Compensator",	
	"reflex":"Reflex Sight",
	"holo":"Holographic Sight",
	"acog":"Acog Sight",
	"extended_m9":"Extended Mag",
	"extended_uzi":"Extended Mag",
	"short_uzi":"Short Mag",
	"stock_uzi":"Uzi Stock",
}

onready var attachment_values: Dictionary = {
	"suppressor1":{
		"damage":-2,
		"accuracy":4,
		"concealment":-2,
		"price":10000,
	},
	"suppressor2":{
		"damage":-5,
		"accuracy":-4,
		"concealment":-1,
		"price":10000,
	},
	"suppressor3":{
		"damage":0,
		"accuracy":10,
		"concealment":-3,
		"price":10000,
	},
	"compensator1":{
		"damage":2,
		"accuracy":4,
		"concealment":-2,
		"price":10000,
	},
	"compensator2":{
		"damage":5,
		"accuracy":-5,
		"concealment":-1,
		"price":10000,
	},
	"compensator3":{
		"damage":3,
		"accuracy":5,
		"concealment":-4,
		"price":10000,
	},
	"reflex":{
		"accuracy":5,
		"concealment":-1,
		"price":10000,
	},
	"holo":{
		"accuracy":10,
		"concealment":-2,
		"price":10000,
	},
	"acog":{
		"accuracy":15,
		"concealment":-3,
		"price":10000,
	},
	"short_uzi":{
		"mag_size": -10,
		"accuracy":0,
		"concealment":2,
		"price":10000,
	},
	"extended_uzi":{
		"mag_size": 10,
		"accuracy":0,
		"concealment":-2,
		"price":10000,
	},
	"extended_m9":{
		"mag_size": 2,
		"accuracy":0,
		"concealment":-2,
		"price":10000,
	},
	"stock_uzi":{
		"accuracy":20,
		"concealment":-3,
		"price":10000,
	},
}

onready var weapon_attachments: Dictionary = {
	"M9":{
		"barrel":["suppressor1","suppressor2","suppressor3","compensator1","compensator2","compensator3"],
		"sight":["reflex"],
		"magazine":["extended_m9"],
		"stock":[]
	},
	"UZI":{
		"barrel":["suppressor1","suppressor2","suppressor3","compensator1","compensator2","compensator3"],
		"sight":["reflex","holo","acog"],
		"magazine":["extended_uzi","short_uzi"],
		"stock":["stock_uzi"]
	},
}

onready var armor_values: Dictionary = {
	"Suit":{
		"protection":0,
		"durability":0,
		"dodge":15,
		"speed":1
	},
	"Light":{
		"protection":50,
		"durability":5,
		"dodge":10,
		"speed":0.95
	},
	"Medium":{
		"protection":65,
		"durability":3.5,
		"dodge":5,
		"speed":0.9
	},
	"Heavy":{
		"protection":75,
		"durability":2.5,
		"dodge":0,
		"speed":0.85
	},
	"Full":{
		"protection":85,
		"durability":1.5,
		"dodge":0,
		"speed":0.75
	},
}

onready var item_amounts: Dictionary = {
	"Medic Bag":2,
	"Ammo Bag":2,
	"ECM":1,
	"C4":3,
	"Sentry":1
}

onready var item_info: Dictionary = {
	"Medic Bag":"Heals for 25% health",
	"Ammo Bag":"Refills ammo for carried weapon only",
	"ECM":"Lasts for 6s",
	"C4":"",
	"Sentry":""
}

onready var item_previews: Dictionary = {
	"M9":"res://src/Menus/Inventory/assets/m9_preview.png",
	"UZI":"res://src/Menus/Inventory/assets/uzi_preview.png",
	
	"Suit":"res://src/Menus/Inventory/assets/suit_preview.png",
	"Light":"res://src/Menus/Inventory/assets/light_preview.png",
	"Medium":"res://src/Menus/Inventory/assets/medium_preview.png",
	"Heavy":"res://src/Menus/Inventory/assets/heavy_preview.png",
	"Full":"res://src/Menus/Inventory/assets/full_preview.png",

	"Medic Bag":"res://src/Menus/Inventory/assets/medic_preview.png",
	"Ammo Bag":"res://src/Menus/Inventory/assets/ammo_preview.png",
	"ECM":"res://src/Menus/Inventory/assets/ecm_preview.png",
	"C4":"res://src/Menus/Inventory/assets/c4_preview.png",
	"Sentry":"res://src/Menus/Inventory/assets/turret_preview.png",
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

onready var bag_speed_penalties: Dictionary = {
	"empty":1,
	"guard":0.75,
	"civilian":0.75,
	"employee":0.75,
	"manager":0.75,
	"drill":0.75,
	"gold":0.65,
	"money":0.85
}

onready var weapon_list: Dictionary = {
	"primary":["UZI"],
	"secondary":["M9"]
}
