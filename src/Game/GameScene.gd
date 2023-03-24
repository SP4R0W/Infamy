extends Node2D
class_name GameScene

var level_paths: Dictionary = {
	"busy":"res://src/Game/Maps/busy/busy.tscn",
	"italy":"res://src/Game/Maps/italy/italy.tscn",
	"bank":"res://src/Game/Maps/bank/bank.tscn"
}

func _ready():
	Game.game_scene = self
	
	Global.root.get_node("menu").stop()
	$Audio/briefing.play()

	load_level()
	
	restart_game()

	show_preplanning()

func restart_game():
	Game.can_spawn = false
	
	Game.max_targets = 3
	Game.current_cops = 0
	
	Game.stolen_cash = Global.contract_values[Game.level]["rewards_mon"] + (Global.contract_values[Game.level]["rewards_mon_bonus"] * Game.difficulty)
	Game.xp_earned = Global.contract_values[Game.level]["rewards_xp"] + (Global.contract_values[Game.level]["rewards_xp_bonus"] * Game.difficulty)
	
	Game.killed_civilians_penalty = 0
	Game.stolen_cash_bags = 0
	Game.stolen_cash_loose = 0
	Game.xp_earned_stealth = 0
	Game.xp_earned_bags = 0
	
	Game.map_assets = []

	Game.player_current_equipment = 0
	Game.player_inventory = []

	Game.is_game_loud = false
	Game.player_weapon = -1
	Game.player_disguise = "normal"
	Game.player_status = Game.player_statuses.NORMAL

	Game.player_bag = "empty"
	Game.player_bag_has_disguise = false

	Game.player_can_move = true
	Game.player_can_interact = true
	Game.player_can_shoot= true
	Game.player_can_melee = true
	Game.player_can_run = true

	Game.player_is_interacting = false
	Game.suspicious_interaction = false
	Game.player_is_reloading = false
	Game.player_is_meleing = false
	Game.player_is_running = false
	Game.player_is_dead = false

	Game.player_collision_zones = []

	Game.game_process = false

	Game.hostages = 0
	Game.kills = 0

	Game.handcuffs = Game.max_handcuffs
	Game.bodybags = Game.max_bodybags
	
	Game.player_damage_reduction = 0
	
	Game.player.health = Game.player_max_health
	Game.player.stamina = Game.player_max_stamina
	
	Game.desperado_kill_counter = 0
	Game.desperado_active = false
	
	Game.donor_kill_counter = 0

	Game.is_bulletstorm_active = false
	Game.push_it_cooldown = false

	Game.locknload_kill_counter = 0
	Game.locknload_active = false

	Game.unbreakable_cooldown = false
	
	Game.golden_kill_counter = 0
	Game.golden_active = false
	
func load_level() -> void:
	var level = load(level_paths[Game.level]).instance()
	add_child(level)

func start_game() -> void:
	$Audio/briefing.stop()

	show_gameui()

	Game.game_process = true
	Game.map.update_objective(1)
	Game.map.set_assets()

	Game.update_attachments()
	Game.update_armor()

	$Audio/stealth.play()

func _on_Start_btn_pressed() -> void:
	Game.map.check_skills()
	
	Game.check_skills()
	
	Game.player.add_weapons()
	
	start_game()

func _on_Menu_btn_pressed() -> void:
	$Audio/loud.stop()
	$Audio/stealth.stop()

	$Audio/success.stop()
	$Audio/fail.stop()
	
	Savedata.save_data()
	Composer.goto_scene(Global.scene_paths["lobby"],true,true,0.5,0.5,$Audio/briefing,false)

func show_preplanning() -> void:
	$Control/CanvasLayer/Preplanning.show()
	$Control/CanvasLayer/GameUI.hide()
	$Control/CanvasLayer/Heist_success.hide()
	$Control/CanvasLayer/Heist_fail.hide()
	
	$Control/CanvasLayer/GameUI/CanvasLayer2/Inventory.hide()

	$Control/CanvasLayer/Start_btn.show()
	$Control/CanvasLayer/Menu_btn.show()

func show_gameui() -> void:
	$Control/CanvasLayer/GameUI.show()
	$Control/CanvasLayer/Heist_success.hide()
	$Control/CanvasLayer/Heist_fail.hide()

	$Control/CanvasLayer/Preplanning.queue_free()

	$Control/CanvasLayer/Start_btn.queue_free()
	$Control/CanvasLayer/Menu_btn.hide()

func show_gamewin() -> void:
	if (Game.player_bag != "none"):
		if (Global.bag_base_values.keys().has(Game.player_bag)):
			var bag_value = Global.bag_base_values[Game.player_bag] * (Game.difficulty + 1)
			
			Game.stolen_cash += bag_value
			Game.stolen_cash_bags += bag_value
			
			Game.xp_earned += 1000
			Game.xp_earned_bags += 1000
			
	$Control/CanvasLayer/GameUI/CanvasLayer2/Inventory.hide()
	
	$EcmSound.stop()
	Game.game_process = false

	$Audio/stealth.stop()
	$Audio/loud.stop()

	Game.map.queue_free()

	$Audio/success.play()

	$Control/CanvasLayer/Heist_success.show()
	$Control/CanvasLayer/Heist_success.draw_success()

	$Control/CanvasLayer/GameUI.queue_free()

	$Control/CanvasLayer/Menu_btn.show()

func show_gamefail() -> void:
	$Control/CanvasLayer/GameUI/CanvasLayer2/Inventory.hide()
	
	$EcmSound.stop()
	Game.game_process = false

	$Audio/stealth.stop()
	$Audio/loud.stop()

	Game.map.queue_free()
	
	$Audio/fail.play()	

	$Control/CanvasLayer/Heist_fail.show()
	$Control/CanvasLayer/Heist_fail.draw_fail()

	$Control/CanvasLayer/GameUI.queue_free()

	$Control/CanvasLayer/Menu_btn.show()
	
func _process(delta):
	if (!Game.game_process):
		return
		
	if (Input.is_action_just_pressed("reset") && !Game.player_is_dead):
		$EcmSound.stop()
		$Audio/stealth.stop()
		$Audio/loud.stop()
		
		Composer.goto_scene(Global.scene_paths["gamescene"],true,false,0.5,0.5)


func _on_Desperado_timeout():
	Game.desperado_kill_counter = 0

func _on_LocknLoad_timeout():
	Game.locknload_kill_counter = 0

func _on_Bulletstorm_timeout():
	Game.is_bulletstorm_active = false

func _on_Unbreakable_timeout():
	Game.unbreakable_cooldown = false

func _on_PushIt_timeout():
	Game.push_it_cooldown = false

func _on_Golden_timeout():
	Game.golden_active = false
	Game.golden_kill_counter = 0
	
	Game.ui.hide_timer("Golden")

func _on_Golden2_timeout():
	Game.golden_kill_counter = 0
