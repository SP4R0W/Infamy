extends Panel

onready var objective: Label = $Objective/Label

onready var timer: Label = $Status/VBoxContainer/Timer
onready var player_status: Label = $Status/VBoxContainer/Status
onready var player_bag: Label = $Status/VBoxContainer/Carry

onready var hostage_counter: Label = $Counters/VBoxContainer/Hostage
onready var kill_counter: Label = $Counters/VBoxContainer/Kills

onready var inventory: Panel = $Inventory
onready var inventory_box: HBoxContainer = $Inventory/HBoxContainer

onready var weapon1_text: Label = $Player/Weapon1
onready var ammo1_text: Label = $Player/Ammo1
onready var weapon2_text: Label = $Player/Weapon2
onready var ammo2_text: Label = $Player/Ammo2

onready var item1_img: TextureRect = $Player/Item1
onready var item1_text: Label = $Player/Item1_amount
onready var item2_img: TextureRect = $Player/Item2
onready var item2_text: Label = $Player/Item2_amount

onready var health_bar: TextureProgress = $Player/Health_bar
onready var armor_bar: TextureProgress = $Player/Armor_bar
onready var stamina_bar: TextureProgress = $Player/Stamina_bar

var start_time: int = OS.get_system_time_msecs()
var start_time_secs: int = start_time
var start_time_mins: int = start_time

var item_textures: Dictionary = {
	"b_keycard":"res://src/Objects/Blue_keycard/blue_keycard.png"
}

var texture_rects: Array

func _ready() -> void:
	texture_rects = inventory_box.get_children()

func set_ui_timer() -> void:
	var time_difference = OS.get_system_time_msecs() - start_time
	var time_difference_secs = OS.get_system_time_msecs() - start_time_secs
	var time_difference_mins = OS.get_system_time_msecs() - start_time_mins
	
	var seconds = floor(time_difference_secs / 1000)
	if (seconds == 60):
		start_time_secs = OS.get_system_time_msecs()
		
	var minutes = floor(time_difference_mins / 60000)
	if (minutes == 60):
		start_time_mins = OS.get_system_time_msecs()
		
	var hours = floor(time_difference / 3600000)
	
	if (hours == 0):
		timer.text = "%02d:%02d" % [minutes,seconds]
	else:
		timer.text = "%02d:%02d:%02d" % [hours,minutes,seconds]

func set_player_status() -> void:
	match Game.player_status:
		Game.player_statuses.NORMAL:
			player_status.text = "Normal"
			player_status.modulate = Color(1,1,1,1)
		Game.player_statuses.DISGUISED:
			player_status.text = "Disguised"
			player_status.modulate = Color(1,1,1,1)
		Game.player_statuses.TRESPASSING:
			player_status.text = "Trespassing"
			player_status.modulate = Color(1,0,0,1)
		Game.player_statuses.SUSPICIOUS:
			player_status.text = "Suspicious"
			player_status.modulate = Color(1,0,0,1)
		Game.player_statuses.ARMED:
			player_status.text = "Armed"
			player_status.modulate = Color(1,0,0,1)
		Game.player_statuses.COMPROMISED:
			player_status.text = "Compromised"
			player_status.modulate = Color(1,0,0,1)
			
func set_player_bag_text() -> void:
	player_bag.text = "Bag: " + Game.player_bag.capitalize()
	
func draw_player_inventory() -> void:
	if (Game.player_inventory.size() == 0):
		inventory.hide()
	else:
		inventory.show()
		
		for i in range(texture_rects.size()):
			var rect = texture_rects[i]
			
			if (range(Game.player_inventory.size()).has(i)):
				var item = Game.player_inventory[i]
				
				rect.texture = load(item_textures[item])
			else:
				rect.texture = null
	
func draw_weapon_names() -> void:
	weapon1_text.text = Game.player_weapons[0]
	ammo1_text.text = str(Game.player.weapons[0].current_mag_size) + "/" + str(Game.player.weapons[0].current_ammo_count)
	weapon2_text.text = Game.player_weapons[1]
	ammo2_text.text = str(Game.player.weapons[1].current_mag_size) + "/" + str(Game.player.weapons[1].current_ammo_count)
	
	if (Game.player_weapon == 0):
		weapon1_text.modulate = Color(1,1,1,1)
		ammo1_text.modulate = Color(1,1,1,1)
		
		weapon2_text.modulate = Color(0.54,0.54,0.54,1)
		ammo2_text.modulate = Color(0.54,0.54,0.54,1)
	elif (Game.player_weapon == 1):
		weapon2_text.modulate = Color(1,1,1,1)
		ammo2_text.modulate = Color(1,1,1,1)
		
		weapon1_text.modulate = Color(0.54,0.54,0.54,1)
		ammo1_text.modulate = Color(0.54,0.54,0.54,1)
	else:
		weapon1_text.modulate = Color(0.54,0.54,0.54,1)
		ammo1_text.modulate = Color(0.54,0.54,0.54,1)
		
		weapon2_text.modulate = Color(0.54,0.54,0.54,1)
		ammo2_text.modulate = Color(0.54,0.54,0.54,1)	
		
func draw_player_bars() -> void:
	health_bar.value = 	Game.player.health
	armor_bar.value = Game.player.armor
	stamina_bar.value = Game.player.stamina
			
func _process(delta) -> void:
	if (!Game.game_process):
		return	
		
	set_ui_timer()
	set_player_status()
	set_player_bag_text()
	
	draw_player_inventory()
	draw_weapon_names()
	draw_player_bars()
