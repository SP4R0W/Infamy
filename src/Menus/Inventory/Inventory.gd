extends Node2D

onready var primary_title: Label = $Control/CanvasLayer/Inventory_panel/HBoxContainer/Primary/VBoxContainer/Title
onready var primary_img: TextureRect = $Control/CanvasLayer/Inventory_panel/HBoxContainer/Primary/VBoxContainer/TextureRect
onready var primary_mods: Label = $Control/CanvasLayer/Inventory_panel/HBoxContainer/Primary/VBoxContainer/Mods
onready var primary_stats: Label = $Control/CanvasLayer/Inventory_panel/HBoxContainer/Primary/VBoxContainer/Stats
onready var primary_hidden: Label = $Control/CanvasLayer/Inventory_panel/HBoxContainer/Primary/VBoxContainer/Hidden

onready var secondary_title: Label = $Control/CanvasLayer/Inventory_panel/HBoxContainer/Secondary/VBoxContainer/Title
onready var secondary_img: TextureRect = $Control/CanvasLayer/Inventory_panel/HBoxContainer/Secondary/VBoxContainer/TextureRect
onready var secondary_mods: Label = $Control/CanvasLayer/Inventory_panel/HBoxContainer/Secondary/VBoxContainer/Mods
onready var secondary_stats: Label = $Control/CanvasLayer/Inventory_panel/HBoxContainer/Secondary/VBoxContainer/Stats
onready var secondary_hidden: Label = $Control/CanvasLayer/Inventory_panel/HBoxContainer/Secondary/VBoxContainer/Hidden

onready var armor_title: Label = $Control/CanvasLayer/Inventory_panel/HBoxContainer/Armor/VBoxContainer/Title
onready var armor_img: TextureRect = $Control/CanvasLayer/Inventory_panel/HBoxContainer/Armor/VBoxContainer/TextureRect
onready var armor_stats: Label = $Control/CanvasLayer/Inventory_panel/HBoxContainer/Armor/VBoxContainer/Stats
onready var armor_hidden: Label = $Control/CanvasLayer/Inventory_panel/HBoxContainer/Armor/VBoxContainer/Hidden

onready var item1_title: Label = $Control/CanvasLayer/Inventory_panel/HBoxContainer/Equipment1/VBoxContainer/Title
onready var item1_img: TextureRect = $Control/CanvasLayer/Inventory_panel/HBoxContainer/Equipment1/VBoxContainer/TextureRect
onready var item1_stats: Label = $Control/CanvasLayer/Inventory_panel/HBoxContainer/Equipment1/VBoxContainer/Stats
onready var item1_info: Label = $Control/CanvasLayer/Inventory_panel/HBoxContainer/Equipment1/VBoxContainer/Info

onready var item2_title: Label = $Control/CanvasLayer/Inventory_panel/HBoxContainer/Equipment2/VBoxContainer/Title
onready var item2_img: TextureRect = $Control/CanvasLayer/Inventory_panel/HBoxContainer/Equipment2/VBoxContainer/TextureRect
onready var item2_stats: Label = $Control/CanvasLayer/Inventory_panel/HBoxContainer/Equipment2/VBoxContainer/Stats
onready var item2_info: Label = $Control/CanvasLayer/Inventory_panel/HBoxContainer/Equipment2/VBoxContainer/Info

var selected_loadout: int = 1

func _ready():
	redraw_inventory()

func _on_Menu_btn_pressed():
	Composer.goto_scene(Global.scene_paths["mainmenu"],true,true,0.5,0.5)
	
func redraw_inventory():
	var loadout = Savedata.player_loadouts[selected_loadout]
	
	primary_title.text = loadout["primary"]
	primary_img.texture = load(Global.item_previews[loadout["primary"]])
	
	secondary_title.text = loadout["secondary"]
	secondary_img.texture = load(Global.item_previews[loadout["secondary"]])
	
	armor_title.text = loadout["armor"]
	armor_img.texture = load(Global.item_previews[loadout["armor"]])
	
	item1_title.text = loadout["equipment1"]
	item1_img.texture = load(Global.item_previews[loadout["equipment1"]])
	
	item2_title.text = loadout["equipment2"]
	item2_img.texture = load(Global.item_previews[loadout["equipment2"]])
	


func _on_1_btn_pressed():
	selected_loadout = 1
	redraw_inventory()


func _on_2_btn_pressed():
	selected_loadout = 2
	redraw_inventory()


func _on_3_btn_pressed():
	selected_loadout = 3
	redraw_inventory()
