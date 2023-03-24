extends Node

# special scenes for easy access and creating clones (and to prevent multiple preloading from different objects)

var scene_objects: Dictionary = {
	"bag": preload("res://src/Objects/Bags/Bag.tscn"),
	"keys": preload("res://src/Objects/Keys/Keys.tscn"),
	"alert": preload("res://src/Zones/AlertZone/AlertZone.tscn"),
	
	"ammo":preload("res://src/Objects/Ammo Box/AmmoBox.tscn"),
	
	"cop": preload("res://src/NPCs/Cops/Cop.tscn"),
	"shield": preload("res://src/NPCs/Cops/Shield.tscn"),
	"heavy": preload("res://src/NPCs/Cops/Heavy.tscn"),
	
	"plr_bullet": preload("res://src/Weapons/Player_bullet.tscn"),
	"enm_bullet": preload("res://src/Weapons/Enemy_bullet.tscn"),
	"c4": preload("res://src/Equipment/C4/C4.tscn"),
	
	"inventory_item":preload("res://src/Game/InventoryItem/InventoryItem.tscn")
}

# All the possible alarm codes when reporting a crime

var alarm_codes: Dictionary = {
	"camera_player":"Camera spotted a criminal.",
	"camera_body":"Camera spotted a body.",
	"camera_hostage":"Camera spotted a hostage.",
	"camera_alert":"Camera spotted an alerted person.",
	"camera_bag":"Camera spotted a suspicious bag.",
	"camera_drill":"Camera spotted a drill.",
	"camera_glass":"Camera spotted broken glass.",
	"camera_door":"Camera spotted a broken door.",
	"hostage_escaped":"Hostage escaped and raised the alarm.",
	"guard_player":"Guard spotted a criminal.",
	"guard_body":"Guard spotted a body.",
	"guard_hostage":"Guard spotted a hostage.",
	"guard_alert":"Guard spotted an alerted person.",
	"guard_bag":"Guard spotted a suspicious bag.",
	"guard_drill":"Guard spotted a drill.",
	"guard_glass":"Guard spotted broken glass.",
	"guard_camera":"Guard spotted a broken camera.",
	"guard_noise":"Guard heard a suspicious noise.",
	"guard_door":"Guard spotted a broken door.",
	"civilian_player":"Civilian spotted a criminal.",
	"civilian_body":"Civilian spotted a body.",
	"civilian_hostage":"Civilian spotted a hostage.",
	"civilian_alert":"Civilian spotted an alerted person.",
	"civilian_bag":"Civilian spotted a suspicious bag.",
	"civilian_drill":"Civilian spotted a drill.",
	"civilian_glass":"Civilian spotted broken glass.",
	"civilian_camera":"Civilian spotted a broken camera.",
	"civilian_noise":"Civilian heard a suspicious noise.",
	"civilian_door":"Civilian spotted a broken door.",
}

# game_scene refers to the GameScene.tscn - a scene which handles node placement, map loading, UI showing, etc.
var game_scene = null

# this is reponsible for stopping the game at preplanning
var game_process: bool = false

# obvious
var is_game_loud = false

# this refers to spawners, and whether or not they should actually spawn cops
var can_spawn = false

# in-game level name
var level: String = ""

# game difficulty and its names
var difficulty: int = 0
var difficulty_names: Array = ["Easy","Normal","Hard","Very Hard"]

var max_cops = 25
var current_cops = 0

# This sets the maximum amount of objects an NPC or Camera can detect at once.
var max_targets = 3

# These are exceptions which are ignored by detecting objects
var exceptions = []

# this is a reference to GameUI
var ui

var map
var map_nav
var map_objects
var map_guard_restpoints
var map_empl_restpoints
var map_escape_zone

# an array storing all the assets the player has bought for the map
var map_assets: Array = []

# representation of stolen loot and xp for end screens
var stolen_cash = 0
var stolen_cash_bags = 0
var stolen_cash_loose = 0
var killed_civilians_penalty = 0

var xp_earned = 0
var xp_earned_bags = 0
var xp_earned_stealth = 0

var is_ecm_on: bool = false

var detection_sound_playing = false

# a player reference and all of its properties
var player

var player_weapons: Array = ["",""]
var player_attachments: Dictionary = {

}
var player_armor: String = "Suit"
var player_equipment: Array = [["",0],["",0]]
var player_current_equipment: int = 0

var player_inventory: Array = []
var player_skills

enum player_statuses {
	NORMAL,
	DISGUISED,
	TRESPASSING,
	SUSPICIOUS,
	ARMED,
	COMPROMISED
}

var player_weapon = -1
var player_disguise = "normal"
var player_status = player_statuses.NORMAL

var player_bag: String = "empty"
var player_bag_has_disguise: bool = false

var player_can_move: bool = true
var player_can_interact: bool = true
var player_can_shoot: bool = true
var player_can_melee: bool = true
var player_can_run: bool = true
var player_can_use_equipment: bool = true

var player_is_interacting: bool = false
var suspicious_interaction: bool = false
var player_is_reloading: bool = false
var player_is_meleing: bool = false
var player_is_running: bool = false
var player_is_dead: bool = false

var player_damage_reduction = 0

var player_max_health = 100
var player_max_stamina = 100

# this stores all the zones responsible for "restricted" areas that player is currently in.
var player_collision_zones: Array = []

var hostages = 0
var kills = 0

var max_handcuffs = 3
var handcuffs = 3

var max_bodybags = 1
var bodybags = 1

# skill related variables

var desperado_kill_counter = 0
var desperado_active = false

var locknload_kill_counter = 0
var locknload_active = false

var golden_kill_counter = 0
var golden_active = false

var donor_kill_counter = 0

var is_bulletstorm_active = false

var unbreakable_cooldown = false
var push_it_cooldown = false

var max_equipment_amounts: Dictionary = {
	"Medic Bag":2,
	"Ammo Bag":2,
	"ECM":1,
	"C4":3
}

# a simple function to create a temporary timer
func create_temp_timer(time,object,function):
	get_tree().create_timer(time).connect("timeout",object,function)

# add an exception to detecting objects
func add_exception(object):
	if (!exceptions.has(object)):
		exceptions.append(object)
		
		get_tree().call_group("Detection","add_exception",object)

# remove an exception to detecting objects
func remove_exception(object):
	if (exceptions.has(object)):
		exceptions.erase(object)
		
		get_tree().call_group("Detection","remove_exception",object)

# draw attachments for weapons
func update_attachments():
	Game.player.weapons[0].draw_attachments()
	Game.player.weapons[1].draw_attachments()

func update_armor():
	# Suit doesn't have any armor.
	if (player_armor != "Suit"):
		Game.player.armor = 100
	else:
		Game.player.armor = 0

func activate_ecm():
	# Show the timer responsible for ECM duration
	Game.ui.show_timer("ECM")
	
	# set the correct ECM duration
	var ecm_timer = Game.game_scene.get_node("Timers/ECM")
	ecm_timer.wait_time = 6
	
	if (get_skill("infiltrator",4,1) != "none"):
		ecm_timer.wait_time = 15
	elif (get_skill("infiltrator",1,1) == "upgraded"):
		ecm_timer.wait_time = 10
	
	if (Game.get_skill("infiltrator",4,3) == "upgraded"):
		Game.player_damage_reduction += 50
	
	# check whether or not the timer is connected to a correct function
	if (!ecm_timer.is_connected("timeout",self,"ecm_timeout")):
		ecm_timer.connect("timeout",self,"ecm_timeout")
	
	# start the timer and play the sound	
	ecm_timer.start()
	
	Game.game_scene.get_node("EcmSound").play()	
	Game.is_ecm_on = true	
	
func ecm_timeout():
	# hide the timer and stop the sound
	if (is_instance_valid(Game.ui)):
		Game.ui.hide_timer("ECM")
		Game.is_ecm_on = false
		Game.game_scene.get_node("EcmSound").stop()
		
	if (Game.get_skill("infiltrator",4,3) == "upgraded"):
		Game.player_damage_reduction -= 50

func turn_game_loud(code: String):
	# only run this if it hasn't been run before
	if (not is_game_loud):
		Game.max_targets = 1
		
		game_scene.get_node("Audio/stealth").stop()

		is_game_loud = true
		map.loud_ready()
		
		# avoid possible crash
		if (code):
			ui.update_popup("Alarm sounded: " + alarm_codes[code],4)
		else:
			ui.update_popup("Alarm was sounded.")

		game_scene.get_node("Audio/loud").play()

# a simple function for checking whether the player has specific equipment
func has_item_in_equipment(item_needed: String) -> bool:
	for item in player_equipment:
		if item[0] == item_needed:
			return true

	return false

# a simple function for checking whether the player has the specific amount of a specific equipment
func get_amount_of_equipment(item_needed: String) -> int:
	for item in player_equipment:
		if item[0] == item_needed:
			return item[1]

	return 0

# decrease the equipment amount and switch to other equipment if decreased
func use_player_equipment(equipment):
	for item in player_equipment:
		if item[0] == equipment:
			item[1] -= 1

			if (item[1] == 0):
				if (Game.player_current_equipment == 0):
					Game.player_current_equipment = 1
				else:
					Game.player_current_equipment = 0

# stop the interaction break
func stop_interaction_grace():
	player_can_interact = true

# add an item to inventory (max 12 items)
func add_player_inventory_item(item):
	var index = player_inventory.size()
	
	if (player_inventory.size() < 11):
		player_inventory.append(item)
	
	if (Game.ui != null):
		var new_item = scene_objects["inventory_item"].instance()
		
		var inv = Game.ui.get_node("CanvasLayer2/Inventory/HBoxContainer")
		inv.add_child(new_item)
		
		new_item.item = item

func change_player_disguise(disguise):
	player_disguise = disguise
	player_status = player_statuses.DISGUISED

func carry_bag(bag,has_disguise):
	player_bag = bag
	player_bag_has_disguise = has_disguise
	player.add_bag()

func spawn_bag():
	var bag = scene_objects["bag"].instance()
	map_objects.add_child(bag)

	bag.global_position = player.global_position
	bag.bag_type = player_bag
	bag.has_disguise = player_bag_has_disguise

	player_bag = "empty"

func kill_player():
	player_is_dead = true

	player_weapon = -1

	player_can_move = false
	player_can_interact = false
	player_can_shoot = false
	player_can_melee = false
	player_can_run = false

	player_is_interacting = false
	suspicious_interaction = false
	player_is_reloading = false
	player_is_meleing = false
	player_is_running = false

	player_collision_zones = []

	yield(get_tree().create_timer(1),"timeout")

	Game.game_scene.show_gamefail()

# a simple function for getting the actual skill (the order in dictionaries is kinda messed up)
func get_skill(prof,tier,skill) -> String:
	var index
	
	match tier:
		1:
			index = 11
		2:
			index = 8
		3:
			index = 5
		4:
			index = 2
	
	match skill:
		1:
			index -= 2
		2:
			index -= 1
		3:
			index -= 0
	
	return player_skills[prof][index]

# some skill specific checks
func check_skills():
	if (get_skill("mastermind",4,1) == "basic"):
		Game.player_max_health = 125
	elif (get_skill("mastermind",4,1) == "upgraded"):
		Game.player_max_health = 150
	else:
		Game.player_max_health = 100
		
	if (get_skill("engineer",4,2) == "upgraded"):
		Game.player_damage_reduction += 25
	
	if (is_instance_valid(Game.player)):
		Game.player.health = Game.player_max_health
		
		if (get_skill("infiltrator",1,2) != "none"):
			Game.player.walkSpeed *= 1.25
			Game.player.runSpeed *= 1.25
			if (get_skill("infiltrator",1,2) == "upgraded"):
				Game.player_max_stamina = 125
			else:
				Game.player_max_stamina = 100
		else:
			Game.player.walkSpeed = 500
			Game.player.runSpeed = 1000
			Game.player_max_stamina = 100
	
	if (get_skill("mastermind",1,2) != "none"):
		max_handcuffs = 6
		handcuffs = 6
		
	if (get_skill("infiltrator",2,1) == "upgraded"):
		max_bodybags = 2
		bodybags = 2

	var m_tier2_1 = get_skill("mastermind",2,1)
	var c_tier3_1 = get_skill("commando",3,1)
	var e_tier2_2 = get_skill("engineer",2,2)
	var i_tier1_1 = get_skill("infiltrator",1,1)
	var i_tier4_1 = get_skill("infiltrator",4,1)
	
	if (m_tier2_1 != "none"):
		if (m_tier2_1 == "basic"):
			max_equipment_amounts["Medic Bag"] = 4
		else:
			max_equipment_amounts["Medic Bag"] = 6
	else:
		max_equipment_amounts["Medic Bag"] = 2
		
	if (player_equipment[0][0] == "Medic Bag"):
		player_equipment[0][1] = max_equipment_amounts["Medic Bag"]
	elif (player_equipment[1][0] == "Medic Bag"):
		player_equipment[1][1] = max_equipment_amounts["Medic Bag"]
		
		
	if (c_tier3_1 != "none"):
		if (c_tier3_1 == "basic"):
			max_equipment_amounts["Ammo Bag"] = 3
		else:
			max_equipment_amounts["Ammo Bag"] = 5
	else:
		max_equipment_amounts["Ammo Bag"] = 2
		
	if (player_equipment[0][0] == "Ammo Bag"):
		player_equipment[0][1] = max_equipment_amounts["Ammo Bag"]
	elif (player_equipment[1][0] == "Ammo Bag"):
		player_equipment[1][1] = max_equipment_amounts["Ammo Bag"]
		
	if (e_tier2_2 != "none"):
		if (e_tier2_2 == "basic"):
			max_equipment_amounts["C4"] = 6
		else:
			max_equipment_amounts["C4"] = 9
	else:
		max_equipment_amounts["C4"] = 3
		
	if (player_equipment[0][0] == "C4"):
		player_equipment[0][1] = max_equipment_amounts["C4"]
	elif (player_equipment[1][0] == "C4"):
		player_equipment[1][1] = max_equipment_amounts["C4"]

	if (i_tier1_1 != "none" && i_tier4_1 != "upgraded"):
		max_equipment_amounts["ECM"] = 2
	else:
		if (i_tier4_1 == "upgraded"):
			max_equipment_amounts["ECM"] = 4
		else:		
			max_equipment_amounts["ECM"] = 1
		
	if (player_equipment[0][0] == "ECM"):
		player_equipment[0][1] = max_equipment_amounts["ECM"]
	elif (player_equipment[1][0] == "ECM"):
		player_equipment[1][1] = max_equipment_amounts["ECM"]

	var pref = Savedata.player_stats["preffered_loadout"]
	
	if (get_skill("commando",4,2) == "none"):
		
		if (Savedata.player_loadouts[pref]["armor"] == "Full"):
			Savedata.player_loadouts[pref]["armor"] = "Suit"
			player_armor = "Suit"
	
	if (get_skill("engineer",4,1) == "none"):
		Savedata.player_loadouts[pref]["equipment2"] = "none"
	elif (get_skill("engineer",4,1) == "basic"):
		var equip2 = Savedata.player_loadouts[pref]["equipment2"]
	
		if (equip2 != "none"):
			player_equipment[1][1] = ceil(max_equipment_amounts[equip2] / 2)
			
	
