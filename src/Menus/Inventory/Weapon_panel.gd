extends Panel

onready var parent = get_parent().get_parent().get_parent()
onready var panel = $ScrollContainer/GridContainer
onready var desc_panel = $Desc

var selected_loadout: int = 1

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

	if (!button.is_connected("pressed",self,"_on_Button_pressed")):
		button.connect("pressed",self,"_on_Button_pressed",[button])
	
	for weapon in Global.weapon_list[index_translations[weapon_id]]:
		for btn in panel.get_children():
			btn.hide()
			btn.get_node("equip").hide()
			if (weapon == btn.name):
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
		
	var new_string = "Base Statistics:\nDamage: {dmg}\nAccuracy: {acc}\nMag Size: {mag}\nAmmo Count: {ammo}\nConcealment: {con}".format({
		"dmg":new_damage,
		"acc":new_acc,
		"mag":new_mag,
		"ammo":new_ammo,
		"con":new_con
	})
	
	desc_panel.get_node("VBoxContainer/Stats").text = new_string
	desc_panel.get_node("VBoxContainer/Old").text = old_string
	desc_panel.get_node("VBoxContainer/Button").show()
	
	if (Savedata.owned_weapons.has(selected_weapon)):
		desc_panel.get_node("VBoxContainer/Button").text = "Equip"
	else:
		desc_panel.get_node("VBoxContainer/Button").text = "Buy"
		

func _on_Button_pressed(button):
	var cur_weapon = Savedata.player_loadouts[selected_loadout][index_translations[weapon_id]]
	
	if (button.text == "Equip"):
		Savedata.player_loadouts[selected_loadout][index_translations[weapon_id]] = selected_loadout
	else:
		Savedata.owned_weapons.append(cur_weapon)
		
		desc_panel.get_node("VBoxContainer/Button").text = "Equip"

	cur_weapon = Savedata.player_loadouts[selected_loadout][index_translations[weapon_id]]
	
	for btn in panel.get_children():
		btn.get_node("equip").hide()
		if (btn.name == cur_weapon):
			btn.get_node("equip").show()
