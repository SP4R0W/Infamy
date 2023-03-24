extends TabContainer

onready var parent = get_parent().get_parent().get_parent()

var selected_loadout: String = "1"
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
	var mod = index_translations[tab]
	var modifications = Global.weapon_attachments[edited_gun][mod]
	
	if (modifications.size() == 0):
		current_tab = selected_tab
		parent.get_node("Wrong").play()
		return
		
	current_tab = tab
	selected_tab = tab
	var weapon_attachment = Savedata.player_loadouts[selected_loadout][index_weapon_translations[weapon_id]][index_translations[tab]]
	
	var panel = get_child(selected_tab).get_node("GridContainer")
	var desc_panel = get_child(selected_tab).get_node("Desc/VBoxContainer")
	
	for node in desc_panel.get_children():
		if (node is Label):
			node.text = ""
	
	for button in panel.get_children():
		button.hide()
		button.get_node("equip").hide()
		if (!button.is_connected("pressed",self,"_attachment_pressed")):
			button.connect("pressed",self,"_attachment_pressed",[button])
			
	var button = desc_panel.get_node("Button")
	button.hide()

	if (!button.is_connected("pressed",self,"_on_Button_pressed")):
		button.connect("pressed",self,"_on_Button_pressed",[button])
	
	for child in panel.get_children():
		child.hide()

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
	var base_type = weapon_stats["type"]	
	
	if (base_type == "sniper" && Game.get_skill("mastermind",1,3) == "upgraded"):
		base_acc *= 1.1
	elif (base_type == "automatic" && Game.get_skill("engineer",1,3) == "upgraded"):
		base_damage *= 1.1
	elif (base_type == "shotgun"):	
		if (Game.get_skill("commando",1,3) == "basic"):
			base_damage *= 1.1
		elif (Game.get_skill("commando",1,3) == "upgraded"):
			base_damage *= 1.25
			
		if (Game.get_skill("commando",3,3) == "upgraded"):
			base_damage *= 2
	
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
				
			if (selected_attachment.find("suppressor") != -1):
				if (Game.get_skill("infiltrator",1,3) == "basic"):
					new_acc *= 1.1
				elif (Game.get_skill("infiltrator",1,3) == "upgraded"):
					new_acc *= 1.2
					
				if (Game.get_skill("infiltrator",2,3) != "none"):
					new_con += 1
					if (Game.get_skill("infiltrator",2,3) == "upgraded"):
						new_con += 2
					
				if (Game.get_skill("infiltrator",3,3) == "basic"):
					new_damage *= 1.15
				elif (Game.get_skill("infiltrator",3,3) == "upgraded"):
					new_damage *= 1.3
				
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
					
				if (attachment.find("suppressor") != -1):
					if (Game.get_skill("infiltrator",1,3) == "basic"):
						new_acc *= 1.1
					elif (Game.get_skill("infiltrator",1,3) == "upgraded"):
						new_acc *= 1.2
						
					if (Game.get_skill("infiltrator",2,3) != "none"):
						new_con += 1
						if (Game.get_skill("infiltrator",2,3) == "upgraded"):
							new_con += 2
						
					if (Game.get_skill("infiltrator",3,3) == "basic"):
						new_damage *= 1.15
					elif (Game.get_skill("infiltrator",3,3) == "upgraded"):
						new_damage *= 1.3
					
	if (new_acc > 100):
		new_acc = 100
	elif (new_acc < 0):
		new_acc = 0
				
	if (new_con > 10):
		new_con = 10
	elif (new_con < 0):
		new_con = 0
				
				
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
				
			if (attachment.find("suppressor") != -1):
				if (Game.get_skill("infiltrator",1,3) == "basic"):
					old_acc *= 1.1
				elif (Game.get_skill("infiltrator",1,3) == "upgraded"):
					old_acc *= 1.2
					
				if (Game.get_skill("infiltrator",2,3) != "none"):
					old_con += 1
					if (Game.get_skill("infiltrator",2,3) == "upgraded"):
						old_con += 2
					
				if (Game.get_skill("infiltrator",3,3) == "basic"):
					old_damage *= 1.15
				elif (Game.get_skill("infiltrator",3,3) == "upgraded"):
					old_damage *= 1.3
		
	if (old_acc > 100):
		old_acc = 100
	elif (old_acc < 0):
		old_acc = 0
				
	if (old_con > 10):
		old_con = 10
	elif (old_con < 0):
		old_con = 0
		
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
	
	panel.get_node("Desc/VBoxContainer/Price").text = "Price: " + Global.format_str_commas(str(Global.attachment_values[selected_attachment]["price"])) + "$"
	
	panel.get_node("Desc/VBoxContainer/Owned").text = "Owned: " + str(Savedata.owned_attachments[selected_attachment])

func _attachment_pressed(button):
	var panel = get_child(selected_tab)
	var weapon_attachment = Savedata.player_loadouts[selected_loadout][index_weapon_translations[weapon_id]][index_translations[selected_tab]]
	
	selected_attachment = button.name
	
	if (!Savedata.owned_attachments.keys().has(selected_attachment)):
		Savedata.owned_attachments[selected_attachment] = 0
	
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
	
	var price = Global.attachment_values[selected_attachment]["price"]
	
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
	elif (button.text == "Buy"):
		if (Savedata.player_stats["money"] >= price && Savedata.owned_attachments[selected_attachment] < 100):
			parent.get_node("Buy").play()
			Savedata.player_stats["money"] -= price
			Savedata.owned_attachments[selected_attachment] += 1
			button.text = "Equip"
			
			desc_panel.get_node("VBoxContainer/Owned").text = "Owned: " + str(Savedata.owned_attachments[selected_attachment])
			
			parent.update_money()
		else:
			parent.get_node("Wrong").play()
			if (Savedata.player_stats["money"] < price):
				button.text = "Can't afford!"
			elif (Savedata.owned_attachments[selected_attachment] >= 100):
				Savedata.owned_attachments[selected_attachment] = 100
				button.text = "Can't buy!"
			
			get_tree().create_timer(1).connect("timeout",self,"change_button",[button])
	
		
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

func change_button(button):
	if (button.text == "Can't buy!" || button.text == "Can't afford!"):
		button.text = "Buy"
