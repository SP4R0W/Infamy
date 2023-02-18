extends TabContainer

onready var parent = get_parent().get_parent().get_parent()

var selected_loadout: int = 1
var selected_tab: int = 0

var edited_gun: String = "M9"
var selected_attachment = ""
var weapon_id: int = 1

var index_translations: Dictionary = {
	0:"barrel",
	1:"sight",
	2:"magazine",
	3:"stock"
}

var index_weapon_translations: Dictionary = {
	0:"attachments_primary",
	1:"attachments_secondary",
}

func draw_modify(tab: int):
	selected_tab = tab
	var weapon_attachment = Savedata.player_loadouts[selected_loadout][index_weapon_translations[weapon_id]][index_translations[tab]]
	
	var panel = get_child(selected_tab).get_node("GridContainer")
	var desc_panel = get_child(selected_tab).get_node("Desc")
	
	for button in panel.get_children():
		button.hide()
		button.get_node("equip").hide()
		if (!button.is_connected("pressed",self,"_attachment_pressed")):
			button.connect("pressed",self,"_attachment_pressed",[button])
			
	var button = desc_panel.get_node("VBoxContainer/Button")

	if (!button.is_connected("pressed",self,"_on_Button_pressed")):
		button.connect("pressed",self,"_on_Button_pressed",[button])
	
	for child in panel.get_children():
		child.hide()
	
	var mod = index_translations[selected_tab]
	
	var modifications = Global.weapon_attachments[edited_gun][mod]
	
	for attachment in modifications:
		for btn in panel.get_children():
			if (attachment == btn.name):
				btn.show()
				if (attachment == weapon_attachment):
					btn.get_node("equip").show()
					_attachment_pressed(btn)
				break
				
func calculate_values():
	var panel = get_child(selected_tab)
	var tab = 	index_translations[selected_tab]
	
	var weapon_stats = Global.weapon_base_values[edited_gun]
	
	var cur_attachments = Savedata.player_loadouts[selected_loadout][index_weapon_translations[weapon_id]]
	var cur_attachment_stats
	
	if (Savedata.player_loadouts[selected_loadout][index_weapon_translations[weapon_id]][index_translations[selected_tab]] != ""):
		cur_attachment_stats = Global.attachment_values[Savedata.player_loadouts[selected_loadout][index_weapon_translations[weapon_id]][index_translations[selected_tab]]]
	else:
		cur_attachment_stats = ""
		
	var base_damage = weapon_stats["damage"]
	var base_mag = weapon_stats["magsize"]
	var base_acc = weapon_stats["accuracy"]
	var base_con = weapon_stats["concealment"]
	
	var new_damage = base_damage
	var new_mag = base_mag
	var new_acc = base_acc
	var new_con = base_con
	
	for type in cur_attachments:
		var attachment = cur_attachments[type]
		var attachment_stats
		if (tab == type):
			attachment_stats = Global.attachment_values[selected_attachment]
				
			if (attachment_stats.keys().has("damage")):
				new_damage += attachment_stats["damage"]
					
			if (attachment_stats.keys().has("mag_size")):
				new_mag += attachment_stats["mag_size"]

			if (attachment_stats.keys().has("accuracy")):
				new_acc += attachment_stats["accuracy"]
					
			if (attachment_stats.keys().has("concealment")):
				new_con += attachment_stats["concealment"]
		else:
			if (attachment != ""):
				attachment_stats = Global.attachment_values[attachment]
					
				if (attachment_stats.keys().has("damage")):
					new_damage += attachment_stats["damage"]
						
				if (attachment_stats.keys().has("mag_size")):
					new_mag += attachment_stats["mag_size"]

				if (attachment_stats.keys().has("accuracy")):
					new_acc += attachment_stats["accuracy"]
						
				if (attachment_stats.keys().has("concealment")):
					new_con += attachment_stats["concealment"]
				
	var old_damage = base_damage
	var old_mag = base_mag
	var old_acc = base_acc
	var old_con = base_con
	
	for type in cur_attachments:
		var attachment = cur_attachments[type]
		if (attachment != ""):
			var attachment_stats = Global.attachment_values[attachment]
			
			if (attachment_stats.keys().has("damage")):
				old_damage += attachment_stats["damage"]
					
			if (attachment_stats.keys().has("mag_size")):
				old_mag += attachment_stats["mag_size"]

			if (attachment_stats.keys().has("accuracy")):
				old_acc += attachment_stats["accuracy"]
					
			if (attachment_stats.keys().has("concealment")):
				old_con += attachment_stats["concealment"]
		
	var old_string = "Current Statistics:\nDamage: {dmg}\nAccuracy: {acc}\nMag Size: {mag}\nConcealment: {con}".format({
		"dmg":old_damage,
		"acc":old_acc,
		"mag":old_mag,
		"con":old_con
		})
	
	panel.get_node("Desc/VBoxContainer/Old_stats").text = old_string
	
	var new_string = "New Statistics:\nDamage: {dmg} ({dmg_v})\nAccuracy: {acc} ({acc_v})\nMag Size: {mag} ({mag_v})\nConcealment: {con} ({con_v})".format({
		"dmg":new_damage,
		"acc":new_acc,
		"mag":new_mag,
		"con":new_con,
		"dmg_v":new_damage-old_damage,
		"mag_v":new_mag-old_mag,
		"acc_v":new_acc-old_acc,
		"con_v":new_con-old_con
		})
	
	panel.get_node("Desc/VBoxContainer/Stats").text = new_string
	
	panel.get_node("Desc/VBoxContainer/Price").text = "Price: " + str(Global.attachment_values[selected_attachment]["price"]) + "$"
	
	panel.get_node("Desc/VBoxContainer/Owned").text = "Owned: " + str(Savedata.owned_attachments[selected_attachment])

func _attachment_pressed(button):
	var panel = get_child(selected_tab)
	var weapon_attachment = Savedata.player_loadouts[selected_loadout][index_weapon_translations[weapon_id]][index_translations[selected_tab]]
	
	selected_attachment = button.name
	
	panel.get_node("Desc/VBoxContainer/Title").text = Global.weapon_attachment_names[selected_attachment]
	panel.get_node("Desc/VBoxContainer/Price").text = "Price: 10,000$"
	panel.get_node("Desc/VBoxContainer/Owned").text = "Owned: " + str(Savedata.owned_attachments[selected_attachment])
	panel.get_node("Desc/VBoxContainer/Button").show()
	
	calculate_values()
	
	if (selected_attachment == weapon_attachment):
		panel.get_node("Desc/VBoxContainer/Button").text = "Unequip"
	else:
		if (Savedata.owned_attachments[selected_attachment] < 1):
			panel.get_node("Desc/VBoxContainer/Button").text = "Buy"
		else:
			panel.get_node("Desc/VBoxContainer/Button").text = "Equip"

func _on_Button_pressed(button):
	var panel = get_child(selected_tab).get_node("GridContainer")
	var desc_panel = get_child(selected_tab).get_node("Desc")
	
	var weapon = Savedata.player_loadouts[selected_loadout][index_weapon_translations[weapon_id]]
	var weapon_attachment = Savedata.player_loadouts[selected_loadout][index_weapon_translations[weapon_id]][index_translations[selected_tab]]
	
	if (button.text == "Unequip"):
		Savedata.owned_attachments[selected_attachment] += 1
		Savedata.player_loadouts[selected_loadout][index_weapon_translations[weapon_id]][index_translations[selected_tab]] = ""
		
		calculate_values()
		button.text = "Equip"
	elif (button.text == "Equip"):
		if (weapon_attachment != ""):
			Savedata.owned_attachments[weapon_attachment] += 1
		Savedata.owned_attachments[selected_attachment] -= 1
		Savedata.player_loadouts[selected_loadout][index_weapon_translations[weapon_id]][index_translations[selected_tab]] = selected_attachment
		
		calculate_values()
		
		button.text = "Unequip"
	else:
		Savedata.owned_attachments[selected_attachment] += 1
		button.text = "Equip"
		
		desc_panel.get_node("VBoxContainer/Owned").text = "Owned: " + str(Savedata.owned_attachments[selected_attachment])
		
		
	var modifications = Global.weapon_attachments[edited_gun][index_translations[selected_tab]]
	var searched = Savedata.player_loadouts[selected_loadout][index_weapon_translations[weapon_id]][index_translations[selected_tab]]
	
	for attachment in modifications:
		for btn in panel.get_children():
			if (attachment == btn.name):
				btn.show()
				btn.get_node("equip").hide()
				if (attachment == searched):
					btn.get_node("equip").show()
				break
