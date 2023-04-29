extends Panel

onready var parent = get_parent().get_parent().get_parent()
onready var panel = $GridContainer
onready var desc_panel = $Desc

var selected_loadout: String = "1"

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
	
	var stats: int = Game.max_equipment_amounts[selected_equipment]
	var description: String = Global.item_info[selected_equipment]
	
	if (selected_equipment == "Medic Bag"):
		var tier3_1 = Game.get_skill("mastermind",3,1)
		
		if (tier3_1 != "none"):
			if (tier3_1 == "basic"):
				description = "Heals for 50% health"
			else:
				description = "Heals for 85% health"
		else:
			description = "Heals for 25% health"
	elif (selected_equipment == "Ammo Bag"):
		var tier2_1 = Game.get_skill("commando",2,1)
		
		if (tier2_1 != "none"):
			description = "Refills ammo for both weapons"
		else:
			description = "Refills ammo for carried weapon only"
	elif (selected_equipment == "ECM"):
		if (Game.get_skill("infiltrator",4,1) != "none"):
			description = "Lasts for 15s"
		elif (Game.get_skill("infiltrator",1,1) == "upgraded"):
			description =  "Lasts for 10s"
		else:
			description =  "Lasts for 6s"
	
	if (item_id == 2 && Game.get_skill("engineer",4,1) == "basic"):
		stats = ceil(stats / 2)
	
	if (stats == 0):
		stats = 1

	desc_panel.get_node("VBoxContainer/Title").text = selected_equipment
	desc_panel.get_node("VBoxContainer/Stats").text = "Amount: " + str(stats) + "\n" + description
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
		if (item_id == 1):
			if (Savedata.player_loadouts[selected_loadout]["equipment2"] == selected_equipment):
				parent.get_node("Wrong").play()
				button.text = "Already equipped!"
				
				get_tree().create_timer(1).connect("timeout",self,"change_button",[button])	
				return
		elif (item_id == 2):
			if (Savedata.player_loadouts[selected_loadout]["equipment1"] == selected_equipment):
				parent.get_node("Wrong").play()
				button.text = "Already equipped!"
				
				get_tree().create_timer(1).connect("timeout",self,"change_button",[button])
				return
				
		Savedata.player_loadouts[selected_loadout][index_translations[item_id]] = selected_equipment
		
		button.text = "Unequip"
		
	cur_equipment = Savedata.player_loadouts[selected_loadout][index_translations[item_id]]
	
	for btn in panel.get_children():
		btn.get_node("equip").hide()
		if (btn.name == cur_equipment):
			btn.get_node("equip").show()

func change_button(button):
	if (button.text == "Already equipped!"):
		button.text = "Equip"
