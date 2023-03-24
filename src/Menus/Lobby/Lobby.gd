extends Node2D

onready var menu_track: AudioStreamPlayer = Global.root.get_node("menu")

var selected_diff: int = 0
var selected_heist: String = ""

var heist_ids: Dictionary = {
	0:"bank"
}

var heist_info: Dictionary = {
	"bank":{
		"title":"Downtown Hit",
		"desc":"A small bank downtown. High security, but lots of stuff in its vault, because their transport \"miraculously\" couldn't visit them. You in?",
		"plan":"Plan:\n- Scout the area\n- Find the vault\n- Open the vault\n- Secure the loot\n- Escape!",
		"marker_pos":Vector2(3365,1210)
	}
}

func _ready() -> void:
	if (!menu_track.playing):
		menu_track.play()
	
	$Control/CanvasLayer/Marker.hide()
	$Control/CanvasLayer/Browser_panel.show()
	$Control/CanvasLayer/Heist_panel.hide()

func _on_Menu_btn_pressed() -> void:
	Composer.goto_scene(Global.scene_paths["mainmenu"],true,true,0.5,0.5,menu_track)

func _on_HeistList_item_activated(index) -> void:
	selected_heist = heist_ids[index]
	
	$Control/CanvasLayer/Browser_panel.hide()
	$Control/CanvasLayer/Heist_panel.show()
	
	$Control/CanvasLayer/Marker.show()
	$Control/CanvasLayer/Marker.rect_global_position = heist_info[selected_heist]["marker_pos"]
	
	$Control/CanvasLayer/Heist_panel/VBoxContainer/Title.text = heist_info[selected_heist]["title"]
	$Control/CanvasLayer/Heist_panel/VBoxContainer/Description.text = heist_info[selected_heist]["desc"]
	$Control/CanvasLayer/Heist_panel/VBoxContainer/Plan.text = heist_info[selected_heist]["plan"]
	$Control/CanvasLayer/Heist_panel/VBoxContainer/Total.text = calculate_rewards()
	
func calculate_rewards() -> String:
	var total_money = Global.format_str_commas(Global.contract_values[selected_heist]["rewards_mon"] + (Global.contract_values[selected_heist]["rewards_mon_bonus"] * selected_diff))
	var total_xp = Global.format_str_commas(Global.contract_values[selected_heist]["rewards_xp"] + (Global.contract_values[selected_heist]["rewards_xp_bonus"] * selected_diff))
	
	return "Potential rewards: " + total_money + "$ & " + total_xp + " XP"

func _on_Difficulty_selector_item_selected(index):
	selected_diff = index
	
	$Control/CanvasLayer/Heist_panel/VBoxContainer/Total.text = calculate_rewards()

func _on_PlayButton_pressed():
	$Control/CanvasLayer/Heist_panel/VBoxContainer/Control3/Difficulty_selector.disabled = true
	
	Game.level = selected_heist
	Game.difficulty = selected_diff

	Composer.goto_scene(Global.scene_paths["gamescene"],true,false,0.5,0.5,menu_track,false)

func _on_BackButton_pressed():
	$Control/CanvasLayer/Marker.hide()
	$Control/CanvasLayer/Browser_panel.show()
	$Control/CanvasLayer/Heist_panel.hide()
