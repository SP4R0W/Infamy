extends Node

var scene_objects: Dictionary = {
	"bag": "res://src/Objects/Bags/Bag.tscn",
	"keys": "res://src/Objects/Keys/Keys.tscn",
}

var alarm_codes: Dictionary = {
	"camera_player":"Camera spotted a criminal.",
	"camera_body":"Camera spotted a body.",
	"camera_hostage":"Camera spotted a hostage.",
	"camera_alert":"Camera spotted an alerted person.",
	"camera_bag":"Camera spotted a suspicious bag.",
	"camera_drill":"Camera spotted a drill.",
	"camera_glass":"Camera spotted broken glass.",
	"hostage_escaped":"Hostage escaped and raised the alarm.",
	"guard_player":"Guard spotted a criminal.",
	"guard_body":"Guard spotted a body.",
	"guard_hostage":"Guard spotted a hostage.",
	"guard_alert":"Camera spotted an alerted person.",
	"guard_bag":"Guard spotted a suspicious bag.",
	"guard_drill":"Guard spotted a drill.",
	"guard_glass":"Guard spotted broken glass.",
	"guard_camera":"Guard spotted a broken camera.",
	"guard_noise":"Guard heard a suspicious noise.",
	"civilian_player":"Civilian spotted a criminal.",
	"civilian_body":"Civilian spotted a body.",
	"civilian_hostage":"Civilian spotted a hostage.",
	"civilian_alert":"Civilian spotted an alerted person.",
	"civilian_bag":"Civilian spotted a suspicious bag.",
	"civilian_drill":"Civilian spotted a drill.",
	"civilian_glass":"Civilian spotted broken glass.",
	"civilian_camera":"Civilian spotted a broken camera.",
	"civilian_noise":"Civilian heard a suspicious noise.",
}

var game_scene = null
var game_process: bool = false

var game_scene_map_path: String = ""

var is_game_loud = false

var level: String = ""
var difficulty: int = 0

var difficulty_names: Array = ["Easy","Normal","Hard","Very Hard"]

var ui

var map
var map_nav
var map_objects
var map_guard_restpoints
var map_empl_restpoints
var map_escape_zone

var map_assets: Array = []

var player

var player_weapons: Array = ["UZI","M9"]
var player_armor: String = "Suit"
var player_equipment: Array = [["Medic Bag",2],["Ammo Bag",8]]
var player_current_equipment: int = 0

var player_inventory: Array = []

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

var player_is_interacting: bool = false
var suspicious_interaction: bool = false
var player_is_reloading: bool = false
var player_is_meleing: bool = false
var player_is_running: bool = false

var player_collision_zones: Array = []

var hostages = 0
var kills = 0

var max_handcuffs = 6
var handcuffs = 6

var max_bodybags = 2
var bodybags = 2

var max_equipment_amounts: Dictionary = {
	"Medic Bag":2,
	"Ammo Bag":2,
	"ECM":4,
	"C4":9,
	"Sentry":1,
	"Body Bags":2
}

func turn_game_loud(code: String):
	if (not is_game_loud):
		game_scene.get_node("Audio/stealth").stop()
		
		is_game_loud = true
		map.loud_ready()
		ui.update_popup("Alarm sounded: " + alarm_codes[code],4)
		
		game_scene.get_node("Audio/loud").play()

func has_item_in_equipment(item_needed: String) -> bool:
	for item in player_equipment:
		if item[0] == item_needed:
			return true
			
	return false
	
func get_amount_of_equipment(item_needed: String) -> int:
	for item in player_equipment:
		if item[0] == item_needed:
			return item[1]
		
	return 0
	
func use_player_equipment(equipment):
	for item in player_equipment:
		if item[0] == equipment:
			item[1] -= 1

func stop_interaction_grace():
	player_can_interact = true

func add_player_inventory_item(item):
	if (player_inventory.size() < 8):
		player_inventory.append(item)

func change_player_disguise(disguise):
	player_disguise = disguise
	player_status = player_statuses.DISGUISED
	
func carry_bag(bag,has_disguise):
	player_bag = bag
	player_bag_has_disguise = has_disguise
	player.add_bag()

func spawn_bag():
	var bag = load(scene_objects["bag"]).instance()
	map_objects.add_child(bag)
	
	bag.global_position = player.global_position
	bag.bag_type = player_bag
	bag.has_disguise = player_bag_has_disguise
	
	player_bag = "empty"
