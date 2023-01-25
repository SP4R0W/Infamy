extends Panel

onready var objective: PanelContainer = $Objective
onready var subtitle: Label = $Subtitle
onready var popup: Panel = $Popup_panel

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

onready var green_effect: TextureRect = $Green_effect
onready var red_effect: TextureRect = $Red_effect

var start_time: int = OS.get_system_time_msecs()
var start_time_secs: int = start_time
var start_time_mins: int = start_time

var item_textures: Dictionary = {
	"b_keycard":"res://src/Objects/Blue_keycard/blue_keycard.png",
	"r_keycard":"res://src/Objects/Red_keycard/vault_keycard.png",
	"vault_code":"res://src/Objects/Vault_code/vault_code.png",
	"keys":"res://src/Objects/Keys/keys.png",
	"p_number":"res://src/Objects/Phone/phone_number.png"
}

var equipment_textures: Dictionary = {
	"medic":"res://src/Equipment/medic.png",
	"ammo":"res://src/Equipment/ammo.png",
	"c4":"res://src/Equipment/c4.png",
	"ecm":"res://src/Equipment/ecm.png",
}

var texture_rects: Array

var current_subtitle_priority = -1

func _ready() -> void:
	texture_rects = inventory_box.get_children()
	
	popup.hide()
	subtitle.modulate = Color(1,1,1,0)
	
	Game.ui = self

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
		
func draw_player_equipment() -> void:
	item1_img.texture = load(equipment_textures[Game.player_equipment[0][0]])
	item1_text.text = str(Game.player_equipment[0][1]) + "x"
	if (Game.player_current_equipment == 0):
		item1_text.modulate = Color(1,1,1,1)
	else:
		item1_text.modulate = Color(0.54,0.54,0.54,1)
	
	item2_img.texture = null
	item2_text.text = ""
	
	if ((range(Game.player_equipment.size()).has(1))):
		item2_img.texture = load(equipment_textures[Game.player_equipment[1][0]])
		item2_text.text = str(Game.player_equipment[1][1]) + "x"		
		
		if (Game.player_current_equipment == 1):
			item2_text.modulate = Color(1,1,1,1)
		else:
			item2_text.modulate = Color(0.54,0.54,0.54,1)
		
	
		
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
	draw_player_equipment()
	draw_player_bars()
	
func do_green_effect():
	green_effect.modulate = Color(1,1,1,1)
	get_tree().create_tween().tween_property(green_effect,"modulate:a",0.0,0.5)

func do_red_effect():
	red_effect.modulate = Color(1,1,1,1)
	get_tree().create_tween().tween_property(red_effect,"modulate:a",0.0,0.5)
	
func update_objective(objective_str: String):
	$Objective/Tween.interpolate_property(objective,"rect_scale:x",1,0,0.5)
	$Objective/Tween.start()
	
	yield($Objective/Tween,"tween_all_completed")
	
	objective.visible = false
	
	$Objective/Label.text = ""
	objective.rect_size = Vector2(14,105)
	
	$Objective/Label.text = objective_str
	
	objective.visible = true

	$Objective/Tween.interpolate_property(objective,"rect_scale:x",0,1,0.5)
	$Objective/Tween.start()
	
func update_popup(message: String, duration: float):	
	popup.visible = false
	
	$Popup_panel.rect_scale = Vector2(0,1)
	$Popup_panel/Label.text = ""
	
	$Popup_panel/Label.text = message
	
	popup.rect_size = Vector2(14+$Popup_panel/Label.rect_size.x,105)
	
	$Popup_panel.rect_global_position.x = (OS.get_window_safe_area().end.x) - ($Popup_panel.rect_size.x / 2)
	
	popup.visible = true

	$Popup_panel/Tween.interpolate_property(popup,"rect_scale:x",0,1,0.5)
	$Popup_panel/Tween.start()	
	
	yield($Popup_panel/Tween,"tween_all_completed")
	
	$Popup_panel/Timer.wait_time = duration
	$Popup_panel/Timer.start()
	
	yield($Popup_panel/Timer,"timeout")
	
	$Popup_panel/Tween.interpolate_property(popup,"rect_scale:x",1,0,0.5)
	$Popup_panel/Tween.start()	
	
	yield($Popup_panel/Tween,"tween_all_completed")
	
	popup.visible = false
	
func update_subtitle(subtitle_str:String, priority: int, duration: float):
	if (current_subtitle_priority == -1):
		subtitle.text = subtitle_str
		current_subtitle_priority = priority
		
		$Subtitle/Tween.interpolate_property(subtitle,"modulate:a",0,1,0.5)
		$Subtitle/Tween.start()
		
		yield($Subtitle/Tween,"tween_all_completed")
		
		$Subtitle/Timer.wait_time = duration
		$Subtitle/Timer.start()
		
		yield($Subtitle/Timer,"timeout")
		
		current_subtitle_priority = -1
		
		$Subtitle/Tween.interpolate_property(subtitle,"modulate:a",1,0,0.5)
		$Subtitle/Tween.start()			
	else:
		if (current_subtitle_priority <= priority):
			subtitle.text = subtitle_str
			current_subtitle_priority = priority	
			$Subtitle/Timer.stop()
			
			$Subtitle/Timer.wait_time = duration
			$Subtitle/Timer.start()
			
			yield($Subtitle/Timer,"timeout")
			
			current_subtitle_priority = -1
			
			$Subtitle/Tween.interpolate_property(subtitle,"modulate:a",1,0,0.5)
			$Subtitle/Tween.start()		
					

func _exit_tree() -> void:
	Game.ui = null
