extends Node

var bag_scene = preload("res://src/Objects/Bags/Bag.tscn")

var game_scene = null
var game_process: bool = false

var level: String = ""
var difficulty: int = 0

var difficulty_names: Array = ["Easy","Normal","Hard","Very Hard"]

var map
var map_objects

var player

var player_weapons: Array = ["UZI","M9"]

var player_inventory: Array = []

var player_equipment: Array = []

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
var player_is_reloading: bool = false
var player_is_meleing: bool = false
var player_is_running: bool = false

func stop_interaction_grace():
	player_can_interact = true

func add_player_inventory_item(item):
	if (player_inventory.size() < 8):
		player_inventory.append(item)

func change_player_disguise(disguise):
	player_disguise = disguise
	player_status = player_statuses.DISGUISED
	
func carry_bag(bag,has_disguise):
	print(bag)
	player_bag = bag
	player_bag_has_disguise = has_disguise
	player.add_bag()

func spawn_bag():
	var bag = bag_scene.instance()
	map_objects.add_child(bag)
	
	bag.global_position = player.global_position
	print(player_bag)
	bag.bag_type = player_bag
	bag.has_disguise = player_bag_has_disguise
	
	player_bag = "empty"
