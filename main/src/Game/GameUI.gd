extends Panel

onready var objective: PanelContainer = $Objective
onready var subtitle: Label = $Subtitle
onready var popup: PanelContainer = $Popup_panel

onready var timer: Label = $Status/VBoxContainer/Timer
onready var player_status: Label = $Status/VBoxContainer/Status
onready var player_bag: Label = $Status/VBoxContainer/Carry

onready var inventory = $CanvasLayer2/Inventory

onready var hostage_counter: Label = $Counters/CenterContainer/VBoxContainer/Hostage
onready var kill_counter: Label = $Counters/CenterContainer/VBoxContainer/Kills
onready var money_counter: Label = $Money/CenterContainer/Money

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

onready var effect: ColorRect = $Effect

var seconds: int = 0
var minutes: int = 0
var hours: int = 0

var equipment_textures: Dictionary = {
	"Medic Bag":"res://src/Equipment/medic.png",
	"Ammo Bag":"res://src/Equipment/ammo.png",
	"C4":"res://src/Equipment/c4.png",
	"ECM":"res://src/Equipment/ecm.png",
}

var current_subtitle_priority = -1

func _ready() -> void:
	popup.hide()
	subtitle.modulate = Color(1,1,1,0)

	Game.ui = self

func set_ui_timer() -> void:
	seconds += 1
	if (seconds == 60):
		seconds = 0
		minutes += 1
		if (minutes == 60):
			minutes = 0
			hours += 1

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
	if (Game.player_equipment[0][0] != "none"):
		item1_img.show()
		item1_text.show()

		item1_img.texture = load(equipment_textures[Game.player_equipment[0][0]])
		item1_text.text = str(Game.player_equipment[0][1]) + "x"
		if (Game.player_current_equipment == 0):
			item1_text.modulate = Color(1,1,1,1)
		else:
			item1_text.modulate = Color(0.54,0.54,0.54,1)
	else:
		item1_img.hide()
		item1_text.hide()

	if (Game.player_equipment[1][0] != "none"):
		item2_img.show()
		item2_text.show()

		item2_img.texture = load(equipment_textures[Game.player_equipment[1][0]])
		item2_text.text = str(Game.player_equipment[1][1]) + "x"

		if (Game.player_current_equipment == 1):
			item2_text.modulate = Color(1,1,1,1)
		else:
			item2_text.modulate = Color(0.54,0.54,0.54,1)
	else:
		item2_img.hide()
		item2_text.hide()

	$Player/Cable_amount.text = str(Game.handcuffs) + "x"
	$Player/Bags_amount.text = str(Game.bodybags) + "x"

func draw_player_bars() -> void:
	health_bar.max_value = Game.player_max_health

	health_bar.value = 	Game.player.health
	armor_bar.value = Game.player.armor
	stamina_bar.value = Game.player.stamina

func update_timers():
	var ecm = get_node_or_null("Timers/ECM")
	var overdose = get_node_or_null("Timers/Overdose")
	var bulletstorm = get_node_or_null("Timers/Bulletstorm")
	var golden = get_node_or_null("Timers/Golden")

	if (ecm != null && ecm.visible):
		ecm.get_node("Time").text = "ECM: " + str(int(Game.game_scene.get_node("Timers/ECM").time_left + 1))

	if (overdose != null && overdose.visible):
		overdose.get_node("Time").text = "Overdose: " + str(int(Game.game_scene.get_node("Timers/Overdose").time_left + 1))

	if (bulletstorm != null && bulletstorm.visible):
		bulletstorm.get_node("Time").text = "Bulletstorm: " + str(int(Game.game_scene.get_node("Timers/Bulletstorm").time_left + 1))

	if (golden != null && golden.visible):
		golden.get_node("Time").text = "Golden Scout: " + str(int(Game.game_scene.get_node("Timers/Golden").time_left + 1))

func update_money():
	if Game.map.name == "Tutorial":
		return

	var money = Game.stolen_cash - Game.killed_civilians_penalty - (Global.contract_values[Game.level]["rewards_mon"] + (Global.contract_values[Game.level]["rewards_mon_bonus"] * Game.difficulty))

	if (money == 0):
		money_counter.modulate = Color.white
	elif (money > 0):
		money_counter.modulate = Color.green
	else:
		money_counter.modulate = Color.red

	money_counter.text = "Money: " + Global.format_str_commas(money) + "$"

func _process(delta) -> void:
	if (!Game.game_process):
		return

	if ($Timer.time_left <= 0):
		$Timer.start()

	set_player_status()
	set_player_bag_text()

	draw_player_inventory()
	draw_weapon_names()
	draw_player_equipment()
	draw_player_bars()

	update_timers()
	update_money()

	$Counters/CenterContainer/VBoxContainer/Hostage.text = "H:" + str(Game.hostages)
	$Counters/CenterContainer/VBoxContainer/Kills.text = "K:" + str(Game.kills)

func do_green_effect(duration=0.5):
	effect.modulate = Color.green
	get_tree().create_tween().tween_property(effect,"modulate:a",0.0,duration)

func do_red_effect(duration=0.5):
	effect.modulate = Color.red
	get_tree().create_tween().tween_property(effect,"modulate:a",0.0,duration)

func do_white_effect(duration=0.5):
	effect.modulate = Color.white
	get_tree().create_tween().tween_property(effect,"modulate:a",0.0,duration)

func do_effect(color,duration=0.5):
	effect.modulate = color
	get_tree().create_tween().tween_property(effect,"modulate:a",0.0,duration)

func update_objective(objective_str: String):
	$SFX/objective.play()

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
	$Popup_panel/Timer.stop()
	$SFX/secure.play()

	popup.visible = false

	$Popup_panel.rect_scale = Vector2(0,1)
	$Popup_panel/CenterContainer/Label.text = message

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
	if (!Savedata.player_settings["subtitles"]):
		return

	if (current_subtitle_priority == -1):
		subtitle.text = subtitle_str
		current_subtitle_priority = priority

		$Subtitle/Tween.interpolate_property(subtitle,"modulate:a",0,1,0.5)
		$Subtitle/Tween.start()

		yield($Subtitle/Tween,"tween_all_completed")

		$Subtitle/Timer.wait_time = duration
		$Subtitle/Timer.start()
	else:
		if (current_subtitle_priority <= priority):
			subtitle.text = subtitle_str
			current_subtitle_priority = priority
			$Subtitle/Timer.stop()

			$Subtitle/Timer.wait_time = duration
			$Subtitle/Timer.start()

func end_subtitles():
	current_subtitle_priority = -1

	$Subtitle/Tween.interpolate_property(subtitle,"modulate:a",1,0,0.5)
	$Subtitle/Tween.start()

func show_timer(name):
	if (Savedata.player_settings["timers"]):
		var timer = $Timers.get_node_or_null(name)
		if (timer != null):
			timer.show()

func hide_timer(name):
	var timer = $Timers.get_node_or_null(name)
	if (timer != null):
		timer.hide()



