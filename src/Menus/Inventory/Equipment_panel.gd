extends Panel

onready var parent = get_parent().get_parent().get_parent()
onready var panel = $GridContainer
onready var desc_panel = $Desc

var selected_loadout: int = 1

var selected_equipment = ""
var item_id: int = 1

var index_translations: Dictionary = {
	1:"equipment1",
	2:"equipment2",
}

func draw_equip():
	var cur_equipment = Savedata.player_loadouts[selected_loadout][index_translations[item_id]]
	
	for button in panel.get_children():
		if (!button.is_connected("pressed",self,"_attachment_pressed")):
			button.connect("pressed",self,"_attachment_pressed",[button])
			
	var button = desc_panel.get_node("VBoxContainer/Button")

	if (!button.is_connected("pressed",self,"_on_Button_pressed")):
		button.connect("pressed",self,"_on_Button_pressed",[button])
	
	for btn in panel.get_children():
		btn.get_node("equip").hide()
		if (btn.name == cur_equipment):
			btn.get_node("equip").show()
			_attachment_pressed(btn)
			
func _attachment_pressed(button):
	var cur_equipment = Savedata.player_loadouts[selected_loadout][index_translations[item_id]]
	
	selected_equipment = button.name
	
	var stats: int = Global.item_amounts[selected_equipment]
	var info: String = Global.item_info[selected_equipment]
	
	desc_panel.get_node("VBoxContainer/Title").text = selected_equipment
	desc_panel.get_node("VBoxContainer/Stats").text = "Amount: " + str(stats) + "\n" + info
	desc_panel.get_node("VBoxContainer/Button").show()
	
	if (selected_equipment == cur_equipment):
		desc_panel.get_node("VBoxContainer/Button").text = "Unequip"
	else:
		desc_panel.get_node("VBoxContainer/Button").text = "Equip"


func _on_Button_pressed(button):
	var cur_equipment = Savedata.player_loadouts[selected_loadout][index_translations[item_id]]
	
	if (button.text == "Unequip"):
		Savedata.player_loadouts[selected_loadout][index_translations[item_id]] = "none"

		button.text = "Equip"
	elif (button.text == "Equip"):
		Savedata.player_loadouts[selected_loadout][index_translations[item_id]] = selected_equipment
		
		button.text = "Unequip"
		
	cur_equipment = Savedata.player_loadouts[selected_loadout][index_translations[item_id]]
	
	for btn in panel.get_children():
		btn.get_node("equip").hide()
		if (btn.name == cur_equipment):
			btn.get_node("equip").show()
