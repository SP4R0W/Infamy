extends Panel

onready var parent = get_parent().get_parent().get_parent()
onready var panel = $GridContainer
onready var desc_panel = $Desc

var selected_loadout: int = 1

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
		
	var new_string = "Stats:\nProtection: {dmg}%\nDurability: {acc}%\nSpeed reduction: {mag}%\nDodge chance: {con}%".format({
		"dmg":new_armor_stats["protection"],
		"acc":new_armor_stats["durability"],
		"mag":str(abs(new_armor_stats["speed"] - 1) * 100),
		"con":new_armor_stats["dodge"],
	})
	
	desc_panel.get_node("VBoxContainer/Stats").text = new_string
		
	var old_string = "Current Armor:\nProtection: {dmg}%\nDurability: {acc}%\nSpeed reduction: {mag}%\nDodge chance: {con}%".format({
		"dmg":cur_armor_stats["protection"],
		"acc":cur_armor_stats["durability"],
		"mag":str(abs(cur_armor_stats["speed"] - 1) * 100),
		"con":cur_armor_stats["dodge"],
	})
	
	desc_panel.get_node("VBoxContainer/Old").text = old_string
		
	desc_panel.get_node("VBoxContainer/Button").show()
	
	desc_panel.get_node("VBoxContainer/Button").text = "Equip"


func _on_Button_pressed(button):
	var cur_armor = Savedata.player_loadouts[selected_loadout]["armor"]
	
	if (button.text == "Equip"):
		Savedata.player_loadouts[selected_loadout]["armor"] = selected_armor
		
	cur_armor = Savedata.player_loadouts[selected_loadout]["armor"]
	
	for btn in panel.get_children():
		btn.get_node("equip").hide()
		if (btn.name == cur_armor):
			btn.get_node("equip").show()
	
	draw_equip()
