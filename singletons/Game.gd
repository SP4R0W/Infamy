extends Node

var scene_objects: Dictionary = {
	"bag": "res://src/Objects/Bags/Bag.tscn",
	"keys": "res://src/Objects/Keys/Keys.tscn",
}

var alarm_codes: Dictionary = {
	"camera_player":"Camera spotted a criminal.",
	"camera_body":"Camera spotted a body.",
	"camera_hostage":"Camera spotted a hostage.",
	"camera_bag":"Camera spotted a suspicious bag.",
	"camera_drill":"Camera spotted a drill.",
	"camera_glass":"Camera spotted broken glass."
}

var game_scene = null
var game_process: bool = false

var is_game_loud = false

var level: String = ""
var difficulty: int = 0

var difficulty_names: Array = ["Easy","Normal","Hard","Very Hard"]

var ui

var map
var map_objects

var player

var player_weapons: Array = ["UZI","M9"]

var player_inventory: Array = []

var player_equipment: Array = [["ecm",4],["c4",8]]
var player_current_equipment: int = 0

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

func turn_game_loud(code: String):
	if (not is_game_loud):
		is_game_loud = true
		map.loud_ready()
		ui.update_popup(alarm_codes[code],4)

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
