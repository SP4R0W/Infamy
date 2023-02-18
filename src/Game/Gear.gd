extends VBoxContainer

onready var equipped_1: Label = $HBoxContainer/Panel/VBoxContainer/Equipped
onready var primary_1: TextureRect = $HBoxContainer/Panel/VBoxContainer/primary
onready var secondary_1: TextureRect = $HBoxContainer/Panel/VBoxContainer/secondary
onready var armor_1: TextureRect = $HBoxContainer/Panel/VBoxContainer/armor
onready var item1_1: TextureRect = $HBoxContainer/Panel/VBoxContainer/Items/item1
onready var item2_1: TextureRect = $HBoxContainer/Panel/VBoxContainer/Items/item2

onready var equipped_2: Label = $HBoxContainer/Panel2/VBoxContainer/Equipped
onready var primary_2: TextureRect = $HBoxContainer/Panel2/VBoxContainer/primary
onready var secondary_2: TextureRect = $HBoxContainer/Panel2/VBoxContainer/secondary
onready var armor_2: TextureRect = $HBoxContainer/Panel2/VBoxContainer/armor
onready var item1_2: TextureRect = $HBoxContainer/Panel2/VBoxContainer/Items/item1
onready var item2_2: TextureRect = $HBoxContainer/Panel2/VBoxContainer/Items/item2

onready var equipped_3: Label = $HBoxContainer/Panel3/VBoxContainer/Equipped
onready var primary_3: TextureRect = $HBoxContainer/Panel3/VBoxContainer/primary
onready var secondary_3: TextureRect = $HBoxContainer/Panel3/VBoxContainer/secondary
onready var armor_3: TextureRect = $HBoxContainer/Panel3/VBoxContainer/armor
onready var item1_3: TextureRect = $HBoxContainer/Panel3/VBoxContainer/Items/item1
onready var item2_3: TextureRect = $HBoxContainer/Panel3/VBoxContainer/Items/item2

var selected_loadout: int = 1

func _ready():
	draw_loadouts()
	select_loadout()	
	
func draw_loadouts():
	var loadout1 = Savedata.player_loadouts[1]
	primary_1.texture = load(Global.item_previews[loadout1["primary"]])
	secondary_1.texture = load(Global.item_previews[loadout1["secondary"]])
	armor_1.texture = load(Global.item_previews[loadout1["armor"]])
	
	if (loadout1["equipment1"] != "none"):
		item1_1.texture = load(Global.item_previews[loadout1["equipment1"]])
	else:
		item1_1.texture = null
		
	if (loadout1["equipment2"] != "none"):
		item2_1.texture = load(Global.item_previews[loadout1["equipment2"]])
	else:
		item2_1.texture = null
	
	var loadout2 = Savedata.player_loadouts[2]	

	primary_2.texture = load(Global.item_previews[loadout2["primary"]])
	secondary_2.texture = load(Global.item_previews[loadout2["secondary"]])
	armor_2.texture = load(Global.item_previews[loadout2["armor"]])
	
	if (loadout2["equipment1"] != "none"):
		item1_2.texture = load(Global.item_previews[loadout2["equipment1"]])
	else:
		item1_2.texture = null
		
	if (loadout2["equipment2"] != "none"):
		item2_2.texture = load(Global.item_previews[loadout2["equipment2"]])
	else:
		item2_2.texture = null
	
	var loadout3 = Savedata.player_loadouts[3]
	
	primary_3.texture = load(Global.item_previews[loadout3["primary"]])
	secondary_3.texture = load(Global.item_previews[loadout3["secondary"]])
	armor_3.texture = load(Global.item_previews[loadout3["armor"]])
	
	if (loadout3["equipment1"] != "none"):
		item1_3.texture = load(Global.item_previews[loadout3["equipment1"]])
	else:
		item1_3.texture = null
		
	if (loadout3["equipment2"] != "none"):
		item2_3.texture = load(Global.item_previews[loadout3["equipment2"]])
	else:
		item2_3.texture = null
	
	equipped_1.hide()
	equipped_2.hide()
	equipped_3.hide()
	
	if (selected_loadout == 1):
		equipped_1.show()
	elif (selected_loadout == 2):
		equipped_2.show()
	else:
		equipped_3.show()
		
func select_loadout():
	var loadout = Savedata.player_loadouts[selected_loadout]
		
	Game.player_weapons[0] = loadout["primary"]
	Game.player_weapons[1] = loadout["secondary"]
	Game.player_armor = loadout["armor"]
	Game.player_equipment[0][0] = loadout["equipment1"]
	Game.player_equipment[0][1] = Game.max_equipment_amounts[loadout["equipment1"]]
	Game.player_equipment[1][0] = loadout["equipment2"]
	Game.player_equipment[1][1] = Game.max_equipment_amounts[loadout["equipment2"]]
	Game.player_attachments[loadout["primary"]] = loadout["attachments_primary"]
	Game.player_attachments[loadout["secondary"]] = loadout["attachments_secondary"]
	
func _on_Button1_pressed():
	selected_loadout = 1
	
	select_loadout()
	
	equipped_1.show()
	equipped_2.hide()
	equipped_3.hide()

func _on_Button2_pressed():
	selected_loadout = 2
	
	select_loadout()	
	
	equipped_1.hide()
	equipped_2.show()
	equipped_3.hide()

func _on_Button3_pressed():
	selected_loadout = 3
	
	select_loadout()	
	
	equipped_1.hide()
	equipped_2.hide()
	equipped_3.show()
