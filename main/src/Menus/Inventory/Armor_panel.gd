extends Panel

onready var parent = get_parent().get_parent().get_parent()
onready var panel = $GridContainer
onready var desc_panel = $Desc

var selected_loadout: String = "1"

var selected_armor = ""

func draw_equip():
	var cur_armor = Savedata.player_loadouts[selected_loadout]["armor"]

	for button in panel.get_children():
		if (!button.is_connected("pressed",self,"_attachment_pressed")):
			button.connect("pressed",self,"_attachment_pressed",[button])

	var button = desc_panel.get_node("VBoxContainer/Button")

	if (!button.is_connected("pressed",self,"_on_Button_pressed")):
		button.connect("pressed",self,"_on_Button_pressed",[button])

	for btn in panel.get_children():
		btn.get_node("equip").hide()
		if (btn.name == cur_armor):
			btn.get_node("equip").show()
			_attachment_pressed(btn)

func _attachment_pressed(button):
	var cur_armor = Savedata.player_loadouts[selected_loadout]["armor"]
	selected_armor = button.name

	var cur_armor_stats = Global.armor_values[cur_armor]
	var new_armor_stats = Global.armor_values[selected_armor]


	if (selected_armor != "Suit"):
		desc_panel.get_node("VBoxContainer/Title").text = selected_armor + " Armor"
	else:
		desc_panel.get_node("VBoxContainer/Title").text = selected_armor

	var protection = new_armor_stats["protection"]
	var durability = new_armor_stats["durability"]

	if (Game.get_skill("commando",1,2) != "none" && selected_armor != "Suit"):
		protection += 10
		if (Game.get_skill("commando",1,2) == "upgraded"):
			durability -= 2.5

	var new_string = "Stats:\nAbsorption: {dmg}%\nStrength: {acc}\nSpeed reduction: {mag}%\nDodge chance: {con}%".format({
		"dmg":protection,
		"acc":durability,
		"mag":str(new_armor_stats["speed"] * 100),
		"con":new_armor_stats["dodge"],
	})

	desc_panel.get_node("VBoxContainer/Stats").text = new_string

	protection = cur_armor_stats["protection"]
	durability = cur_armor_stats["durability"]

	if (Game.get_skill("commando",1,2) != "none" && cur_armor != "Suit"):
		protection += 10
		if (Game.get_skill("commando",1,2) == "upgraded"):
			durability -= 2.5

	var old_string = "Current Armor:\nAbsorption: {dmg}%\nStrength: {acc}\nSpeed reduction: {mag}%\nDodge chance: {con}%".format({
		"dmg":protection,
		"acc":durability,
		"mag":str(cur_armor_stats["speed"] * 100),
		"con":cur_armor_stats["dodge"],
	})

	desc_panel.get_node("VBoxContainer/Old").text = old_string

	desc_panel.get_node("VBoxContainer/Button").show()

	if (selected_armor != cur_armor):
		desc_panel.get_node("VBoxContainer/Button").text = "Equip"
	else:
		desc_panel.get_node("VBoxContainer/Button").text = "Equipped"

func _on_Button_pressed(button):
	var cur_armor = Savedata.player_loadouts[selected_loadout]["armor"]

	if (button.text == "Equip"):
		if (selected_armor == "Full"):
			if (Game.get_skill("commando",4,2) == "none"):
				parent.get_node("Wrong").play()
				button.text = "Need 'Unbreakable'!"

				get_tree().create_timer(1).connect("timeout",self,"change_button",[button])
				return

		Savedata.player_loadouts[selected_loadout]["armor"] = selected_armor

	cur_armor = Savedata.player_loadouts[selected_loadout]["armor"]

	for btn in panel.get_children():
		btn.get_node("equip").hide()
		if (btn.name == cur_armor):
			btn.get_node("equip").show()

	draw_equip()

func change_button(button):
	if (button.text == "Need 'Unbreakable'!"):
		button.text = "Equip"
