extends Node

# This file mostly stores data related to scenes, weapons, heists, attachments etc.

# variables for audio fixes in HTML build
onready var is_HTML: bool = false
onready var music_skip: float = 0

# get the "root" that handles the scene switching
onready var root: Node = get_tree().root.get_node_or_null("Main")


onready var skillMenu: Node2D = null

onready var version: float = 1.1

onready var item_textures: Dictionary = {
	"b_keycard":"res://src/Objects/Blue_keycard/blue_keycard.png",
	"r_keycard":"res://src/Objects/Red_keycard/vault_keycard.png",
	"vault_code":"res://src/Objects/Vault_code/vault_code.png",
	"keys":"res://src/Objects/Keys/keys_inv.png",
	"p_number":"res://src/Objects/Phone/phone_number.png",
	"safe_code":"res://src/Objects/Safe_code/password.png",
}

onready var item_labels: Dictionary = {
	"b_keycard":"Blue Keycard",
	"r_keycard":"Red Keycard",
	"vault_code":"Vault Code",
	"keys":"Keys",
	"p_number":"Phone Number",
	"safe_code":"Safe Code",
}

onready var contract_values = {
	"bank": {
		"rewards_mon":50_000,
		"rewards_mon_bonus":40_000,
		"rewards_xp":10_000,
		"rewards_xp_bonus":5_000,
	}
}

onready var scene_paths: Dictionary = {
	"mainmenu":"res://src/Menus/MainMenu/MainMenu.tscn",
	"inventory":"res://src/Menus/Inventory/Inventory.tscn",
	"skills":"res://src/Menus/Skills/Skills.tscn",
	"settings":"res://src/Menus/Settings/Settings.tscn",
	"help":"res://src/Menus/Help/Help.tscn",
	"credits":"res://src/Menus/Credits/Credits.tscn",
	"lobby":"res://src/Menus/Lobby/Lobby.tscn",
	"tutorial":"res://src/Tutorial/Tutorial.tscn",
	"gamescene":"res://src/Game/GameScene.tscn",
}

onready var weapon_scene_paths: Dictionary = {
	"M9":"res://src/Weapons/M9/M9.tscn",
	"G17":"res://src/Weapons/G17/G17.tscn",
	"Deagle":"res://src/Weapons/Deagle/Deagle.tscn",
	"Bronco":"res://src/Weapons/Bronco/Bronco.tscn",
	"UZI":"res://src/Weapons/UZI/UZI.tscn",
	"M4":"res://src/Weapons/M4/M4.tscn",
	"AK":"res://src/Weapons/AK/AK.tscn",
	"MP5":"res://src/Weapons/MP5/MP5.tscn",
	"AWP":"res://src/Weapons/AWP/AWP.tscn",
	"M110":"res://src/Weapons/M110/M110.tscn",
	"Saiga":"res://src/Weapons/Saiga/Saiga.tscn",
	"Reinfeld":"res://src/Weapons/Reinfeld/Reinfeld.tscn",
}

onready var weapon_attachment_paths: Dictionary = {
	"suppressor1_pistol":"res://src/Weapons/assets/suppressor1_pistol.png",
	"suppressor2_pistol":"res://src/Weapons/assets/suppressor2_pistol.png",
	"suppressor3_pistol":"res://src/Weapons/assets/suppressor3_pistol.png",
	"suppressor1_auto":"res://src/Weapons/assets/suppressor1_auto.png",
	"suppressor2_auto":"res://src/Weapons/assets/suppressor2_auto.png",
	"suppressor3_auto":"res://src/Weapons/assets/suppressor3_auto.png",
	"compensator1_pistol":"res://src/Weapons/assets/compensator1_pistol.png",
	"compensator2_pistol":"res://src/Weapons/assets/compensator2_pistol.png",
	"compensator3_pistol":"res://src/Weapons/assets/compensator3_pistol.png",
	"compensator1_auto":"res://src/Weapons/assets/compensator1_auto.png",
	"compensator2_auto":"res://src/Weapons/assets/compensator2_auto.png",
	"compensator3_auto":"res://src/Weapons/assets/compensator3_auto.png",
	"stock_uzi":"res://src/Weapons/assets/stock_uzi.png",
	"default_m4_stock":"res://src/Weapons/assets/default_m4_stock.png",
	"default_ak_stock":"res://src/Weapons/assets/default_ak_stock.png",
	"default_mp5_stock":"res://src/Weapons/assets/default_mp5_stock.png",
	"wide_stock":"res://src/Weapons/assets/wide_stock.png",
	"short_stock":"res://src/Weapons/assets/short_stock.png",
	"suppressor_shotgun":"res://src/Weapons/assets/suppressor3_auto.png",
	"compensator_shotgun":"res://src/Weapons/assets/compensator2_auto.png",
}

onready var weapon_base_values: Dictionary = {
	"M9":{
		"reload_time":1,
		"reload_time_empty":1.5,
		"firerate":125,
		"magsize":8,
		"ammo_count":72,
		"damage":15,
		"accuracy":60,
		"concealment":8,
		"min_ammo_pickup":2,
		"max_ammo_pickup":5,
		"price":5000,
		"type":"pistol",
	},
	"G17":{
		"reload_time":0.8,
		"reload_time_empty":1.25,
		"firerate":150,
		"magsize":10,
		"ammo_count":90,
		"damage":18,
		"accuracy":45,
		"concealment":7,
		"min_ammo_pickup":3,
		"max_ammo_pickup":8,
		"price":27000,
		"type":"pistol",
	},
	"Deagle":{
		"reload_time":1.5,
		"reload_time_empty":2.25,
		"firerate":75,
		"magsize":7,
		"ammo_count":63,
		"damage":25,
		"accuracy":65,
		"concealment":5,
		"min_ammo_pickup":1,
		"max_ammo_pickup":4,
		"price":120000,
		"type":"pistol",
	},
	"Bronco":{
		"reload_time":2,
		"reload_time_empty":2,
		"firerate":100,
		"magsize":6,
		"ammo_count":54,
		"damage":20,
		"accuracy":50,
		"concealment":6,
		"min_ammo_pickup":1,
		"max_ammo_pickup":3,
		"price":104000,
		"type":"pistol",
	},
	"UZI":{
		"reload_time":1.25,
		"reload_time_empty":1.85,
		"firerate":800,
		"magsize":30,
		"ammo_count":270,
		"damage":15,
		"accuracy":20,
		"concealment":7,
		"min_ammo_pickup":6,
		"max_ammo_pickup":15,
		"price":36000,
		"type":"automatic",
	},
	"M4":{
		"reload_time":2,
		"reload_time_empty":2.5,
		"firerate":600,
		"magsize":30,
		"ammo_count":180,
		"damage":36,
		"accuracy":62,
		"concealment":3,
		"min_ammo_pickup":4,
		"max_ammo_pickup":8,
		"price":243000,
		"type":"automatic",
	},
	"AK":{
		"reload_time":2,
		"reload_time_empty":2.5,
		"firerate":650,
		"magsize":30,
		"ammo_count":210,
		"damage":28,
		"accuracy":44,
		"concealment":4,
		"min_ammo_pickup":5,
		"max_ammo_pickup":10,
		"price":192000,
		"type":"automatic",
	},
	"MP5":{
		"reload_time":1.25,
		"reload_time_empty":2,
		"firerate":500,
		"magsize":30,
		"ammo_count":210,
		"damage":22,
		"accuracy":72,
		"concealment":6,
		"min_ammo_pickup":7,
		"max_ammo_pickup":14,
		"price":95000,
		"type":"automatic",
	},
	"AWP":{
		"reload_time":2.5,
		"reload_time_empty":3.5,
		"firerate":25,
		"magsize":5,
		"ammo_count":25,
		"damage":350,
		"accuracy":92,
		"concealment":0,
		"min_ammo_pickup":1,
		"max_ammo_pickup":2,
		"price":675000,
		"type":"sniper",
	},
	"M110":{
		"reload_time":2,
		"reload_time_empty":2,
		"firerate":50,
		"magsize":10,
		"ammo_count":40,
		"damage":80,
		"accuracy":80,
		"concealment":2,
		"min_ammo_pickup":1,
		"max_ammo_pickup":4,
		"price":412000,
		"type":"sniper",
	},
	"Saiga":{
		"reload_time":2,
		"reload_time_empty":2,
		"firerate":150,
		"magsize":6,
		"ammo_count":36,
		"damage":42,
		"accuracy":14,
		"concealment":3,
		"min_ammo_pickup":1,
		"max_ammo_pickup":3,
		"price":354000,
		"type":"shotgun",
	},
	"Reinfeld":{
		"reload_time":0.5,
		"reload_time_empty":0.5,
		"firerate":50,
		"magsize":8,
		"ammo_count":48,
		"damage":65,
		"accuracy":21,
		"concealment":1,
		"min_ammo_pickup":1,
		"max_ammo_pickup":3,
		"price":278000,
		"type":"shotgun",
	},
}

onready var weapon_attachment_names: Dictionary = {
	"suppressor1_pistol":"Medium Suppressor",
	"suppressor2_pistol":"Cheap Suppressor",
	"suppressor3_pistol":"Hitman Suppressor",
	"suppressor1_auto":"Little Suppressor",
	"suppressor2_auto":"Average Suppressor",
	"suppressor3_auto":"Big Suppressor",
	"suppressor_shotgun":"Punchy Suppressor",
	"compensator1_pistol":"Regular Compensator",
	"compensator2_pistol":"Punchy Compensator",
	"compensator3_pistol":"Big Compensator",
	"compensator1_auto":"Tactical Compensator",
	"compensator2_auto":"Competitor Compensator",
	"compensator3_auto":"Funnel Compensator",
	"compensator_shotgun":"Hunter Compensator",
	"reflex":"Reflex Sight",
	"holo":"Holographic Sight",
	"acog":"Acog Sight",
	"extended_m9":"Extended Mag",
	"extended_g17":"Extended Mag",
	"extended_uzi":"Extended Mag",
	"extended_m4":"Extended Mag",
	"extended_saiga":"Extended Mag",
	"short_m4":"Small Mag",
	"short_uzi":"Short Mag",
	"stock_uzi":"Uzi Stock",
	"wide_stock":"Wide Stock",
	"short_stock":"Short Stock",
}

onready var attachment_values: Dictionary = {
	"suppressor1_pistol":{
		"damage":-2,
		"accuracy":8,
		"concealment":-2,
		"price":12000,
	},
	"suppressor2_pistol":{
		"damage":-5,
		"accuracy":-10,
		"concealment":1,
		"price":5000,
	},
	"suppressor3_pistol":{
		"damage":0,
		"accuracy":10,
		"concealment":-3,
		"price":24000,
	},
	"suppressor1_auto":{
		"damage":-5,
		"accuracy":5,
		"concealment":-1,
		"price":22000,
	},
	"suppressor2_auto":{
		"damage":-2,
		"accuracy":8,
		"concealment":-2,
		"price":37000,
	},
	"suppressor3_auto":{
		"damage":0,
		"accuracy":15,
		"concealment":-3,
		"price":65000,
	},
	"suppressor_shotgun":{
		"damage":4,
		"accuracy":10,
		"concealment":0,
		"price":51000,
	},
	"compensator1_pistol":{
		"damage":5,
		"accuracy":7,
		"concealment":-2,
		"price":15000,
	},
	"compensator2_pistol":{
		"damage":8,
		"accuracy":-8,
		"concealment":-1,
		"price":31000,
	},
	"compensator3_pistol":{
		"damage":12,
		"accuracy":10,
		"concealment":-4,
		"price":53000,
	},
	"compensator1_auto":{
		"damage":3,
		"accuracy":10,
		"concealment":-2,
		"price":18000,
	},
	"compensator2_auto":{
		"damage":10,
		"accuracy":-5,
		"concealment":-1,
		"price":29000,
	},
	"compensator3_auto":{
		"damage":15,
		"accuracy":6,
		"concealment":-3,
		"price":61000,
	},
	"compensator_shotgun":{
		"damage":7,
		"accuracy":-8,
		"concealment":-2,
		"price":57000,
	},
	"reflex":{
		"accuracy":5,
		"concealment":-1,
		"price":23000,
	},
	"holo":{
		"accuracy":10,
		"concealment":-2,
		"price":31000,
	},
	"acog":{
		"accuracy":15,
		"concealment":-3,
		"price":40000,
	},
	"short_uzi":{
		"mag_size": -10,
		"accuracy":0,
		"concealment":2,
		"price":15000,
	},
	"extended_uzi":{
		"mag_size": 10,
		"accuracy":0,
		"concealment":-3,
		"price":33000,
	},
	"extended_m9":{
		"mag_size": 2,
		"accuracy":0,
		"concealment":-2,
		"price":14000,
	},
	"extended_g17":{
		"mag_size": 7,
		"accuracy":0,
		"concealment":-3,
		"price":17000,
	},
	"extended_m4":{
		"mag_size": 10,
		"accuracy":0,
		"concealment":-3,
		"price":26000,
	},
	"extended_ak":{
		"mag_size": 10,
		"accuracy":0,
		"concealment":-3,
		"price":24000,
	},
	"extended_saiga":{
		"mag_size": 4,
		"accuracy":0,
		"concealment":-3,
		"price":31000,
	},
	"short_m4":{
		"mag_size": -10,
		"accuracy":0,
		"concealment":3,
		"price":20000,
	},
	"stock_uzi":{
		"accuracy":20,
		"concealment":-2,
		"price":25000,
	},
	"wide_stock":{
		"accuracy":15,
		"concealment":-2,
		"price":26000,
	},
	"short_stock":{
		"accuracy":-10,
		"concealment":2,
		"price":19000,
	},
}

onready var weapon_attachments: Dictionary = {
	"M9":{
		"barrel":["suppressor1_pistol","suppressor2_pistol","suppressor3_pistol","compensator1_pistol","compensator2_pistol","compensator3_pistol"],
		"sight":["reflex"],
		"magazine":["extended_m9"],
		"stock":[]
	},
	"G17":{
		"barrel":["suppressor1_pistol","suppressor2_pistol","suppressor3_pistol","compensator1_pistol","compensator2_pistol","compensator3_pistol"],
		"sight":["reflex"],
		"magazine":["extended_g17"],
		"stock":[]
	},
	"Deagle":{
		"barrel":["suppressor3_pistol","compensator1_pistol","compensator2_pistol","compensator3_pistol"],
		"sight":["reflex","holo"],
		"magazine":[],
		"stock":[]
	},
	"Bronco":{
		"barrel":["compensator1_pistol","compensator2_pistol","compensator3_pistol"],
		"sight":["reflex","holo"],
		"magazine":[],
		"stock":[]
	},
	"UZI":{
		"barrel":["suppressor1_auto","suppressor2_auto","compensator1_auto","compensator2_auto","compensator3_auto"],
		"sight":["reflex","holo","acog"],
		"magazine":["extended_uzi","short_uzi"],
		"stock":["stock_uzi"]
	},
	"M4":{
		"barrel":["suppressor1_auto","suppressor2_auto","suppressor3_auto","compensator1_auto","compensator2_auto","compensator3_auto"],
		"sight":["reflex","holo","acog"],
		"magazine":["extended_m4","short_m4"],
		"stock":["wide_stock","short_stock"]
	},
	"AK":{
		"barrel":["suppressor1_auto","suppressor2_auto","suppressor3_auto","compensator1_auto","compensator2_auto","compensator3_auto"],
		"sight":["reflex","holo","acog"],
		"magazine":["extended_ak"],
		"stock":["wide_stock","short_stock"]
	},
	"MP5":{
		"barrel":["suppressor1_auto","suppressor2_auto","suppressor3_auto","compensator1_auto","compensator2_auto","compensator3_auto"],
		"sight":["reflex","holo"],
		"magazine":[],
		"stock":["wide_stock"]
	},
	"AWP":{
		"barrel":["suppressor3_auto","compensator2_auto","compensator3_auto"],
		"sight":[],
		"magazine":[],
		"stock":[]
	},
	"M110":{
		"barrel":["suppressor2_auto","suppressor3_auto","compensator2_auto","compensator3_auto"],
		"sight":[],
		"magazine":[],
		"stock":[]
	},
	"Saiga":{
		"barrel":["suppressor_shotgun","compensator_shotgun"],
		"sight":["reflex","holo","acog"],
		"magazine":["extended_saiga"],
		"stock":["wide_stock","short_stock"]
	},
	"Reinfeld":{
		"barrel":["compensator_shotgun"],
		"sight":["reflex","holo"],
		"magazine":[],
		"stock":["wide_stock"]
	},
}

onready var weapon_list: Dictionary = {
	"primary":["UZI","M4","AK","MP5","AWP","M110","Saiga","Reinfeld"],
	"secondary":["M9","G17","Deagle","Bronco"]
}

onready var armor_values: Dictionary = {
	"Suit":{
		"protection":0,
		"durability":0,
		"dodge":15,
		"speed":0
	},
	"Light":{
		"protection":50,
		"durability":9,
		"dodge":10,
		"speed":0.1
	},
	"Medium":{
		"protection":65,
		"durability":7.5,
		"dodge":5,
		"speed":0.2
	},
	"Heavy":{
		"protection":75,
		"durability":4.5,
		"dodge":0,
		"speed":0.25
	},
	"Full":{
		"protection":85,
		"durability":3,
		"dodge":0,
		"speed":0.35
	},
}

onready var item_info: Dictionary = {
	"Medic Bag":"Heals for 25% health",
	"Ammo Bag":"Refills ammo for carried weapon only",
	"ECM":"Lasts for 6s",
	"C4":""
}

onready var item_previews: Dictionary = {
	"M9":"res://src/Menus/Inventory/assets/m9_preview.png",
	"G17":"res://src/Menus/Inventory/assets/g17_preview.png",
	"Deagle":"res://src/Menus/Inventory/assets/deagle_preview.png",
	"Bronco":"res://src/Menus/Inventory/assets/bronco_preview.png",
	"UZI":"res://src/Menus/Inventory/assets/uzi_preview.png",
	"M4":"res://src/Menus/Inventory/assets/m4_preview.png",
	"AK":"res://src/Menus/Inventory/assets/ak_preview.png",
	"MP5":"res://src/Menus/Inventory/assets/mp5_preview.png",
	"AWP":"res://src/Menus/Inventory/assets/awp_preview.png",
	"M110":"res://src/Menus/Inventory/assets/m110_preview.png",
	"Saiga":"res://src/Menus/Inventory/assets/saiga_preview.png",
	"Reinfeld":"res://src/Menus/Inventory/assets/reinfeld_preview.png",

	"Suit":"res://src/Menus/Inventory/assets/suit_preview.png",
	"Light":"res://src/Menus/Inventory/assets/light_preview.png",
	"Medium":"res://src/Menus/Inventory/assets/medium_preview.png",
	"Heavy":"res://src/Menus/Inventory/assets/heavy_preview.png",
	"Full":"res://src/Menus/Inventory/assets/full_preview.png",

	"Medic Bag":"res://src/Menus/Inventory/assets/medic_preview.png",
	"Ammo Bag":"res://src/Menus/Inventory/assets/ammo_preview.png",
	"ECM":"res://src/Menus/Inventory/assets/ecm_preview.png",
	"C4":"res://src/Menus/Inventory/assets/c4_preview.png"
}

onready var music_paths: Dictionary = {
	"Velocity":{
		"stealth":"res://assets/music/Velocity/stealth.ogg",
		"loud":"res://assets/music/Velocity/loud.ogg"
	},
	"Assault":{
		"stealth":"res://assets/music/Assault/stealth.ogg",
		"loud":"res://assets/music/Assault/loud.ogg"
	},
	"Pound":{
		"stealth":"res://assets/music/Pound/stealth.ogg",
		"loud":"res://assets/music/Pound/loud.ogg"
	}
}

onready var bag_speed_penalties: Dictionary = {
	"empty":1,
	"guard":0.35,
	"civilian":0.35,
	"employee":0.35,
	"manager":0.35,
	"drill":0.25,
	"gold":0.35,
	"money":0.15
}

onready var bag_base_values: Dictionary = {
	"gold":61500,
	"money":35000
}

func calculate_levels(cur_xp: int):
	# make sure we don't go over level 100
	if (Savedata.player_stats["level"] < 100):
		Savedata.player_stats["cur_xp"] = cur_xp
		var xp = Savedata.player_stats["needed_xp"] - cur_xp

		if (xp < 0.0):
			Savedata.player_stats["level"] += 1
			Savedata.player_stats["total_xp"] += Savedata.player_stats["needed_xp"]
			Savedata.player_stats["cur_xp"] = 0

			if (int(Savedata.player_stats["level"]) % 10 == 0):
				Savedata.skill_loadouts["1"]["skill_points"] += 3
				Savedata.skill_loadouts["2"]["skill_points"] += 3
				Savedata.skill_loadouts["3"]["skill_points"] += 3
			else:
				Savedata.skill_loadouts["1"]["skill_points"] += 1
				Savedata.skill_loadouts["2"]["skill_points"] += 1
				Savedata.skill_loadouts["3"]["skill_points"] += 1

			calculate_needed_xp(Savedata.player_stats["level"])

			calculate_levels(abs(xp))
		elif (xp == 0.0):
			Savedata.player_stats["level"] += 1
			Savedata.player_stats["total_xp"] += Savedata.player_stats["needed_xp"]
			Savedata.player_stats["cur_xp"] = 0

			if (int(Savedata.player_stats["level"]) % 10 == 0):
				Savedata.skill_loadouts["1"]["skill_points"] += 3
				Savedata.skill_loadouts["2"]["skill_points"] += 3
				Savedata.skill_loadouts["3"]["skill_points"] += 3
			else:
				Savedata.skill_loadouts["1"]["skill_points"] += 1
				Savedata.skill_loadouts["2"]["skill_points"] += 1
				Savedata.skill_loadouts["3"]["skill_points"] += 1

			calculate_needed_xp(Savedata.player_stats["level"])
	else:
		Savedata.player_stats["cur_xp"] = 0

func calculate_needed_xp(level: int):
	# a formula for the next level
	Savedata.player_stats["needed_xp"] = round(2.365 * pow(level+1 - 10,2) + 7800 + (Savedata.player_stats["total_xp"] * 0.5))

func format_str_commas(score) -> String:
	if (int(score) < 1000 || int(score) < -999):
		return str(score)

	# Since gdscript doesn't have an easy way of formatting strings, I used a function from the internet (lol)
	score = str(score)

	var i : int = score.length() - 3
	while i > 0:
		score = score.insert(i, ",")
		i = i - 3
	return score
