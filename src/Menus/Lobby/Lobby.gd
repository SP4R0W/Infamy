extends Node2D

var selected_diff: int = 0
var selected_heist: String = ""

var heist_ids: Dictionary = {
	0:"bank"
}

var heist_info: Dictionary = {
	"busy":{
		"title":"Busy Street",
		"desc":"A small bank downtown. High security, but lots of stuff in its vault, because their transport \"miraculously\" couldn't visit them. You in?",
		"plan":"Plan:\n- Scout the area\n- Find the vault\n- Open the vault\n- Secure the loot\n- Escape!",
		"rewards_mon":100_000,
		"rewards_mon_bonus":50_000,
		"rewards_xp":4_000,
		"rewards_xp_bonus":2_000,
		"marker_pos":Vector2(3365,1210)
	},
	"italy":{
		"title":"Cristalli Abbaglianti",
		"desc":"A small bank downtown. High security, but lots of stuff in its vault, because their transport \"miraculously\" couldn't visit them. You in?",
		"plan":"Plan:\n- Scout the area\n- Find the vault\n- Open the vault\n- Secure the loot\n- Escape!",
		"rewards_mon":100_000,
		"rewards_mon_bonus":50_000,
		"rewards_xp":4_000,
		"rewards_xp_bonus":2_000,
		"marker_pos":Vector2(3365,1210)
	},
	"bank":{
		"title":"Downtown Hit",
		"desc":"A small bank downtown. High security, but lots of stuff in its vault, because their transport \"miraculously\" couldn't visit them. You in?",
		"plan":"Plan:\n- Scout the area\n- Find the vault\n- Open the vault\n- Secure the loot\n- Escape!",
		"rewards_mon":100_000,
		"rewards_mon_bonus":50_000,
		"rewards_xp":4_000,
		"rewards_xp_bonus":2_000,
		"marker_pos":Vector2(3365,1210)
	}
}

func _ready() -> void:
	$Control/CanvasLayer/Marker.hide()
	$Control/CanvasLayer/Browser_panel.show()
	$Control/CanvasLayer/Heist_panel.hide()

func _on_Menu_btn_pressed() -> void:
	Composer.goto_scene(Global.scene_paths["mainmenu"],true,true,0.5,0.5)

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
	var total_money = heist_info[selected_heist]["rewards_mon"] + (heist_info[selected_heist]["rewards_mon_bonus"] * selected_diff)
	var total_xp = heist_info[selected_heist]["rewards_xp"] + (heist_info[selected_heist]["rewards_xp_bonus"] * selected_diff)
	
	return "Potential rewards: " + str(total_money) + "$ & " + str(total_xp) + " XP"

func _on_Difficulty_selector_item_selected(index):
	selected_diff = index
	
	$Control/CanvasLayer/Heist_panel/VBoxContainer/Total.text = calculate_rewards()

func _on_PlayButton_pressed():
	$Control/CanvasLayer/Heist_panel/VBoxContainer/Difficulty_selector.disabled = true
	
	Game.level = selected_heist
	Game.difficulty = selected_diff
	
	Composer.goto_scene(Global.scene_paths["gamescene"],true,false,0.5,0.5)

func _on_BackButton_pressed():
	$Control/CanvasLayer/Marker.hide()
	$Control/CanvasLayer/Browser_panel.show()
	$Control/CanvasLayer/Heist_panel.hide()
