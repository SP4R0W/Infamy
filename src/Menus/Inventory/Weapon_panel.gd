extends Panel

onready var parent = get_parent().get_parent().get_parent()
onready var panel = $ScrollContainer/GridContainer
onready var desc_panel = $Desc

var selected_loadout: String = "1"

var selected_weapon = ""
var weapon_id: int = 1

var index_translations: Dictionary = {
	1:"primary",
	2:"secondary",
}

var index_attachment_translations: Dictionary = {
	1:"attachments_primary",
	2:"attachments_secondary",
}

func draw_equip():
	var cur_weapon = Savedata.player_loadouts[selected_loadout][index_translations[weapon_id]]
	
	for button in panel.get_children():
		if (!button.is_connected("pressed",self,"_attachment_pressed")):
			button.connect("pressed",self,"_attachment_pressed",[button])
			
	var button = desc_panel.get_node("VBoxContainer/Button")
	button.hide()

	if (!button.is_connected("pressed",self,"_on_Button_pressed")):
		button.connect("pressed",self,"_on_Button_pressed",[button])
		
	for btn in panel.get_children():
		btn.hide()
		btn.get_node("equip").hide()
		if (Global.weapon_list[index_translations[weapon_id]].has(btn.name)):
			btn.show()
			if (btn.name == cur_weapon):
				btn.get_node("equip").show()
				_attachment_pressed(btn)
			
func _attachment_pressed(button):
	var cur_weapon = Savedata.player_loadouts[selected_loadout][index_translations[weapon_id]]
	selected_weapon = button.name
	
	var cur_stats = Global.weapon_base_values[cur_weapon]
	
	var new_stats = Global.weapon_base_values[selected_weapon]
	
	desc_panel.get_node("VBoxContainer/Title").text = selected_weapon
	
	var cur_damage = cur_stats["damage"]
	var cur_mag = cur_stats["magsize"]
	var cur_ammo = cur_stats["ammo_count"]
	var cur_acc = cur_stats["accuracy"]
	var cur_con = cur_stats["concealment"]
	var cur_type = cur_stats["type"]
	
	if (cur_type == "sniper" && Game.get_skill("mastermind",1,3) == "upgraded"):
		cur_acc *= 1.1
	elif (cur_type == "automatic" && Game.get_skill("engineer",1,3) == "upgraded"):
		cur_damage *= 1.1
	
	if (cur_acc > 100):
		cur_acc = 100
	elif (cur_acc < 0):
		cur_acc = 0
				
	if (cur_con > 10):
		cur_con = 10
	elif (cur_con < 0):
		cur_con = 0
		
	var old_string = "Current Base Statistics:\nDamage: {dmg}\nAccuracy: {acc}\nMag Size: {mag}\nAmmo Count: {ammo}\nConcealment: {con}".format({
		"dmg":cur_damage,
		"acc":cur_acc,
		"mag":cur_mag,
		"ammo":cur_ammo,
		"con":cur_con
	})
	
	var new_damage = new_stats["damage"]
	var new_mag = new_stats["magsize"]
	var new_ammo = new_stats["ammo_count"]	
	var new_acc = new_stats["accuracy"]
	var new_con = new_stats["concealment"]
	var new_type = new_stats["type"]
	
	if (new_type == "sniper" && Game.get_skill("mastermind",1,3) == "upgraded"):
		new_acc *= 1.1
	elif (new_type == "automatic" && Game.get_skill("engineer",1,3) == "upgraded"):
		new_damage *= 1.1
	elif (new_type == "shotgun"):	
		if (Game.get_skill("commando",1,3) == "basic"):
			new_damage *= 1.1
		elif (Game.get_skill("commando",1,3) == "upgraded"):
			new_damage *= 1.25
			
		if (Game.get_skill("commando",3,3) == "upgraded"):
			new_damage *= 2
	
	if (new_acc > 100):
		new_acc = 100
	elif (new_acc < 0):
		new_acc = 0
				
	if (new_con > 10):
		new_con = 10
	elif (new_con < 0):
		new_con = 0
		
	var new_string = "Base Statistics:\nDamage: {dmg}\nAccuracy: {acc}\nMag Size: {mag}\nAmmo Count: {ammo}\nConcealment: {con}".format({
		"dmg":new_damage,
		"acc":new_acc,
		"mag":new_mag,
		"ammo":new_ammo,
		"con":new_con
	})
	
	desc_panel.get_node("VBoxContainer/Stats").text = new_string
	desc_panel.get_node("VBoxContainer/Old").text = old_string
	desc_panel.get_node("VBoxContainer/Price").show()
	desc_panel.get_node("VBoxContainer/Price").text = "Price: " + Global.format_str_commas(str(Global.weapon_base_values[selected_weapon]["price"])) + "$"
	desc_panel.get_node("VBoxContainer/Button").show()
	
	if (!Savedata.owned_weapons.keys().has(selected_weapon)):
		Savedata.owned_weapons[selected_weapon] = false
		
	if (Savedata.owned_weapons[selected_weapon]):
		if (Savedata.player_loadouts[selected_loadout][index_translations[weapon_id]] == selected_weapon):
			desc_panel.get_node("VBoxContainer/Price").hide()
			desc_panel.get_node("VBoxContainer/Button").text = "Equipped"
		else:
			desc_panel.get_node("VBoxContainer/Price").text = "Owned!"
			desc_panel.get_node("VBoxContainer/Button").text = "Equip"
	else:
		desc_panel.get_node("VBoxContainer/Button").text = "Buy"
		

func _on_Button_pressed(button):
	var cur_weapon = Savedata.player_loadouts[selected_loadout][index_translations[weapon_id]]
	var price = Global.weapon_base_values[selected_weapon]["price"]
	var attachments = Savedata.player_loadouts[selected_loadout][index_attachment_translations[weapon_id]]
	
	if (button.text == "Equip"):
		Savedata.player_loadouts[selected_loadout][index_translations[weapon_id]] = selected_weapon
		cur_weapon = Savedata.player_loadouts[selected_loadout][index_translations[weapon_id]]
		
		for key in attachments.keys():
			var attachment = attachments[key]
			if (!Savedata.owned_attachments.keys().has(attachment)):
				Savedata.owned_attachments[attachment] = 0
				
			Savedata.owned_attachments[attachment] = Savedata.owned_attachments[attachment] + 1
			Savedata.player_loadouts[selected_loadout][index_attachment_translations[weapon_id]][key] = ""
			
	elif (button.text == "Buy"):
		if (Savedata.player_stats["money"] >= price):
			parent.get_node("Buy").play()
			Savedata.player_stats["money"] -= price
			Savedata.owned_weapons[selected_weapon] = true
			desc_panel.get_node("VBoxContainer/Button").text = "Equip"
			
			parent.update_money()
		else:
			parent.get_node("Wrong").play()
			button.text = "Can't afford!"
			
			get_tree().create_timer(1).connect("timeout",self,"change_button",[button])
	
	for btn in panel.get_children():
		btn.get_node("equip").hide()
		if (btn.name == cur_weapon):
			btn.get_node("equip").show()
			break

func change_button(button):
	if (button.text == "Can't afford!"):
		button.text = "Buy"
