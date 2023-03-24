extends Node2D
class_name Inventory

onready var menu_track: AudioStreamPlayer = Global.root.get_node("menu")

onready var inventory_panel: Panel = $Control/CanvasLayer/Inventory_panel
onready var modify_panel: TabContainer = $Control/CanvasLayer/Modify_panel
onready var weapon_panel: Panel = $Control/CanvasLayer/Weapon_panel
onready var armor_panel: Panel = $Control/CanvasLayer/Armor_panel
onready var equipment_panel: Panel = $Control/CanvasLayer/Equipment_panel

func _ready():
	goto_inventory()

	update_money()

func _on_Menu_btn_pressed():
	Savedata.save_data()
	Composer.goto_scene(Global.scene_paths["mainmenu"],true,true,0.5,0.5,menu_track)
	
func update_money():
	$Control/CanvasLayer/Panel/CenterContainer/Money.text = "Money: " + Global.format_str_commas(str(Savedata.player_stats["money"])) + "$"

func goto_inventory():
	Global.root.get_node("click").play()
	
	inventory_panel.show()
	modify_panel.hide()
	weapon_panel.hide()
	armor_panel.hide()
	equipment_panel.hide()
	get_node("Control/CanvasLayer/HBoxContainer/1_btn").show()
	get_node("Control/CanvasLayer/HBoxContainer/2_btn").show()
	get_node("Control/CanvasLayer/HBoxContainer/3_btn").show()
	$Control/CanvasLayer/HBoxContainer/Back_button.hide()
	
	inventory_panel.redraw_inventory()	

func goto_modify():
	Global.root.get_node("click").play()	
	
	inventory_panel.hide()
	modify_panel.show()
	
	get_node("Control/CanvasLayer/HBoxContainer/1_btn").hide()
	get_node("Control/CanvasLayer/HBoxContainer/2_btn").hide()
	get_node("Control/CanvasLayer/HBoxContainer/3_btn").hide()
	$Control/CanvasLayer/HBoxContainer/Back_button.show()

func goto_weapon():
	Global.root.get_node("click").play()	
	
	inventory_panel.hide()
	weapon_panel.show()
	
	get_node("Control/CanvasLayer/HBoxContainer/1_btn").hide()
	get_node("Control/CanvasLayer/HBoxContainer/2_btn").hide()
	get_node("Control/CanvasLayer/HBoxContainer/3_btn").hide()
	$Control/CanvasLayer/HBoxContainer/Back_button.show()
	
	weapon_panel.draw_equip()	
	
func goto_armor():
	Global.root.get_node("click").play()
		
	inventory_panel.hide()
	armor_panel.show()
	
	get_node("Control/CanvasLayer/HBoxContainer/1_btn").hide()
	get_node("Control/CanvasLayer/HBoxContainer/2_btn").hide()
	get_node("Control/CanvasLayer/HBoxContainer/3_btn").hide()
	$Control/CanvasLayer/HBoxContainer/Back_button.show()
	
	armor_panel.draw_equip()
	
func goto_item():
	Global.root.get_node("click").play()
		
	inventory_panel.hide()
	equipment_panel.show()
	
	get_node("Control/CanvasLayer/HBoxContainer/1_btn").hide()
	get_node("Control/CanvasLayer/HBoxContainer/2_btn").hide()
	get_node("Control/CanvasLayer/HBoxContainer/3_btn").hide()
	$Control/CanvasLayer/HBoxContainer/Back_button.show()
	
	equipment_panel.draw_equip()
	
func _on_1_btn_pressed():
	Global.root.get_node("click").play()
		
	Savedata.player_stats["preffered_loadout"] = "1"

	Game.player_skills = Savedata.skill_loadouts[Savedata.player_stats["preffered_loadout"]]
	
	Game.check_skills()
	
	inventory_panel.redraw_inventory()
	


func _on_2_btn_pressed():
	Global.root.get_node("click").play()
	Savedata.player_stats["preffered_loadout"] = "2"

	Game.player_skills = Savedata.skill_loadouts[Savedata.player_stats["preffered_loadout"]]
	
	Game.check_skills()
	
	inventory_panel.redraw_inventory()

func _on_3_btn_pressed():
	Global.root.get_node("click").play()
	Savedata.player_stats["preffered_loadout"] = "3"

	Game.player_skills = Savedata.skill_loadouts[Savedata.player_stats["preffered_loadout"]]
	
	Game.check_skills()
	
	inventory_panel.redraw_inventory()
	
	
func _on_Modify_primary_pressed():
	Global.root.get_node("click").play()
	modify_panel.selected_loadout = inventory_panel.selected_loadout
	modify_panel.edited_gun = Savedata.player_loadouts[inventory_panel.selected_loadout]["primary"]
	modify_panel.weapon_id = 0
	goto_modify()
	
	modify_panel.draw_modify(0)

func _on_Modify_secondary_pressed():
	Global.root.get_node("click").play()
	modify_panel.selected_loadout = inventory_panel.selected_loadout
	modify_panel.edited_gun = Savedata.player_loadouts[inventory_panel.selected_loadout]["secondary"]
	modify_panel.weapon_id = 1
	goto_modify()
	
	modify_panel.draw_modify(0)
	
func _on_Change_pweapon_pressed():
	Global.root.get_node("click").play()
	weapon_panel.selected_loadout = inventory_panel.selected_loadout
	weapon_panel.weapon_id = 1
	goto_weapon()


func _on_Change_sweapon_pressed():
	Global.root.get_node("click").play()
	weapon_panel.selected_loadout = inventory_panel.selected_loadout
	weapon_panel.weapon_id = 2
	goto_weapon()

func _on_Back_button_pressed():
	Global.root.get_node("click").play()
	goto_inventory()

func _on_Change_armor_pressed():
	Global.root.get_node("click").play()
	armor_panel.selected_loadout = inventory_panel.selected_loadout 
	
	goto_armor()

func _on_Change_primary_pressed():
	Global.root.get_node("click").play()
	equipment_panel.selected_loadout = inventory_panel.selected_loadout 
	equipment_panel.item_id = 1
	
	goto_item()

func _on_Change_secondary_pressed():
	Global.root.get_node("click").play()
	equipment_panel.selected_loadout = inventory_panel.selected_loadout 
	equipment_panel.item_id = 2
	
	goto_item()
