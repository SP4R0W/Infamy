extends Panel

onready var parent: Inventory = get_parent().get_parent().get_parent()

onready var primary_title: Label = $HBoxContainer/Primary/VBoxContainer/Title
onready var primary_img: TextureRect = $HBoxContainer/Primary/VBoxContainer/TextureRect
onready var primary_mods: Label = $HBoxContainer/Primary/VBoxContainer/Mods
onready var primary_stats: Label = $HBoxContainer/Primary/VBoxContainer/Stats
onready var primary_hidden: Label = $HBoxContainer/Primary/VBoxContainer/Hidden

onready var secondary_title: Label = $HBoxContainer/Secondary/VBoxContainer/Title
onready var secondary_img: TextureRect = $HBoxContainer/Secondary/VBoxContainer/TextureRect
onready var secondary_mods: Label = $HBoxContainer/Secondary/VBoxContainer/Mods
onready var secondary_stats: Label = $HBoxContainer/Secondary/VBoxContainer/Stats
onready var secondary_hidden: Label = $HBoxContainer/Secondary/VBoxContainer/Hidden

onready var armor_title: Label = $HBoxContainer/Armor/VBoxContainer/Title
onready var armor_img: TextureRect = $HBoxContainer/Armor/VBoxContainer/TextureRect
onready var armor_stats: Label = $HBoxContainer/Armor/VBoxContainer/Stats
onready var armor_hidden: Label = $HBoxContainer/Armor/VBoxContainer/Hidden

onready var item1_title: Label = $HBoxContainer/Equipment1/VBoxContainer/Title
onready var item1_img: TextureRect = $HBoxContainer/Equipment1/VBoxContainer/TextureRect
onready var item1_stats: Label = $HBoxContainer/Equipment1/VBoxContainer/Stats

onready var item2_title: Label = $HBoxContainer/Equipment2/VBoxContainer/Title
onready var item2_img: TextureRect = $HBoxContainer/Equipment2/VBoxContainer/TextureRect
onready var item2_stats: Label = $HBoxContainer/Equipment2/VBoxContainer/Stats

var selected_loadout: int = 1
var edited_gun: String = ""

func _ready():
	redraw_inventory()
	
func redraw_inventory():
	$Title.text = "Your selected loadout (" + str(selected_loadout) + "):"
	var loadout = Savedata.player_loadouts[selected_loadout]
	
	var weapon_stats_primary = Global.weapon_base_values[loadout["primary"]]
	var weapon_stats_secondary = Global.weapon_base_values[loadout["secondary"]]	
	
	var cur_attachments_primary = Savedata.player_loadouts[selected_loadout]["attachments_primary"]
	var cur_attachments_secondary = Savedata.player_loadouts[selected_loadout]["attachments_secondary"]
	
	var base_damage
	var base_mag
	var base_acc
	var base_con
	var base_ammo
	
	var mod_string = "Modifications:"
	var stat_string = ""
	
	primary_title.text = loadout["primary"]
	primary_img.texture = load(Global.item_previews[loadout["primary"]])
	
	for attachment in Savedata.player_loadouts[selected_loadout]["attachments_primary"].values():
		if (attachment != ""):
			mod_string += "\n" + Global.weapon_attachment_names[attachment]
		
	primary_mods.text = mod_string
	
	base_damage = weapon_stats_primary["damage"]
	base_mag = weapon_stats_primary["magsize"]
	base_acc = weapon_stats_primary["accuracy"]
	base_con = weapon_stats_primary["concealment"]
	base_ammo = weapon_stats_primary["ammo_count"]
	
	for type in cur_attachments_primary:
		var attachment = cur_attachments_primary[type]
		if (attachment != ""):
			var attachment_stats = Global.attachment_values[attachment]
			
			if (attachment_stats.keys().has("damage")):
				base_damage += attachment_stats["damage"]
					
			if (attachment_stats.keys().has("mag_size")):
				base_mag += attachment_stats["mag_size"]

			if (attachment_stats.keys().has("accuracy")):
				base_acc += attachment_stats["accuracy"]
					
			if (attachment_stats.keys().has("concealment")):
				base_con += attachment_stats["concealment"]
				
	stat_string = "Stats:\nDamage: {dmg}\nAccuracy: {acc}\nConcealment: {con}\nMag Size: {mag}\nAmmo Count: {ammo}".format({
		"dmg":base_damage,
		"acc":base_acc,
		"mag":base_mag,
		"con":base_con,
		"ammo":base_ammo,
		})
	
	primary_stats.text = stat_string
	
	if (base_con < 8):
		primary_hidden.text = "Visible"
		primary_hidden.modulate = Color.red
	else:
		primary_hidden.text = "Concealed"
		primary_hidden.modulate = Color.dodgerblue
		
	secondary_title.text = loadout["secondary"]
	secondary_img.texture = load(Global.item_previews[loadout["secondary"]])
	
	mod_string = "Modifications:\n"
	
	for attachment in Savedata.player_loadouts[selected_loadout]["attachments_secondary"].values():
		if (attachment != ""):
			mod_string += Global.weapon_attachment_names[attachment] + "\n"
	
	secondary_mods.text = mod_string	
	
	base_damage = weapon_stats_secondary["damage"]
	base_mag = weapon_stats_secondary["magsize"]
	base_acc = weapon_stats_secondary["accuracy"]
	base_con = weapon_stats_secondary["concealment"]
	base_ammo = weapon_stats_secondary["ammo_count"]
	
	for type in cur_attachments_secondary:
		var attachment = cur_attachments_secondary[type]
		if (attachment != ""):
			var attachment_stats = Global.attachment_values[attachment]
			
			if (attachment_stats.keys().has("damage")):
				base_damage += attachment_stats["damage"]
					
			if (attachment_stats.keys().has("mag_size")):
				base_mag += attachment_stats["mag_size"]

			if (attachment_stats.keys().has("accuracy")):
				base_acc += attachment_stats["accuracy"]
					
			if (attachment_stats.keys().has("concealment")):
				base_con += attachment_stats["concealment"]
				
	stat_string = "Stats:\nDamage: {dmg}\nAccuracy: {acc}\nConcealment: {con}\nMag Size: {mag}\nAmmo Count: {ammo}".format({
		"dmg":base_damage,
		"acc":base_acc,
		"mag":base_mag,
		"con":base_con,
		"ammo":base_ammo,
		})
	
	secondary_stats.text = stat_string
	
	if (base_con < 8):
		secondary_hidden.text = "Visible"
		secondary_hidden.modulate = Color.red
	else:
		secondary_hidden.text = "Concealed"
		secondary_hidden.modulate = Color.dodgerblue
		
	armor_title.text = loadout["armor"]
	armor_img.texture = load(Global.item_previews[loadout["armor"]])
	
	var armor_stats_str = "Protection: {dmg}%\nDurability: {acc}%\nSpeed reduction: {mag}%\nDodge chance: {con}%".format({
		"dmg":Global.armor_values[loadout["armor"]]["protection"],
		"acc":Global.armor_values[loadout["armor"]]["durability"],
		"mag":str(abs(Global.armor_values[loadout["armor"]]["speed"] - 1) * 100),
		"con":Global.armor_values[loadout["armor"]]["dodge"],
	})
	
	armor_stats.text = armor_stats_str
	
	if (loadout["armor"] != "Suit" && loadout["armor"] != "Light"):
		armor_hidden.text = "Visible"
		armor_hidden.modulate = Color.red
	else:
		armor_hidden.text = "Concealed"
		armor_hidden.modulate = Color.dodgerblue		
	
	if (loadout["equipment1"] != "none"):
		item1_title.text = loadout["equipment1"]
		item1_img.texture = load(Global.item_previews[loadout["equipment1"]])
		item1_stats.text = "Amount: " + str(Global.item_amounts[loadout["equipment1"]]) + "\n" + Global.item_info[loadout["equipment1"]]
	else:
		item1_title.text = "Empty"
		item1_img.texture = null
		item1_stats.text = ""
	
	if (loadout["equipment2"] != "none"):
		item2_title.text = loadout["equipment2"]
		item2_img.texture = load(Global.item_previews[loadout["equipment2"]])
		item2_stats.text = "Amount: " + str(Global.item_amounts[loadout["equipment2"]]) + "\n" + Global.item_info[loadout["equipment2"]]
	else:
		item2_title.text = "Empty"
		item2_img.texture = null
		item2_stats.text = ""

func goto_inventory():
	$Control/CanvasLayer/Inventory_panel.show()
	$Control/CanvasLayer/Modify_panel.hide()
	get_node("Control/CanvasLayer/HBoxContainer/1_btn").show()
	get_node("Control/CanvasLayer/HBoxContainer/2_btn").show()
	get_node("Control/CanvasLayer/HBoxContainer/3_btn").show()
	$Control/CanvasLayer/HBoxContainer/Back_button.hide()

func goto_modify():
	$Control/CanvasLayer/Inventory_panel.hide()
	$Control/CanvasLayer/Modify_panel.show()
	
	get_node("Control/CanvasLayer/HBoxContainer/1_btn").hide()
	get_node("Control/CanvasLayer/HBoxContainer/2_btn").hide()
	get_node("Control/CanvasLayer/HBoxContainer/3_btn").hide()
	$Control/CanvasLayer/HBoxContainer/Back_button.show()
