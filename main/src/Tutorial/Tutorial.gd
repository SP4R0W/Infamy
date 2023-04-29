extends Node2D

onready var menu_track: AudioStreamPlayer = Global.root.get_node("menu")

var player_scene = load("res://src/Player/Player.tscn")

var objectives: Dictionary = {
	1:{"objective_name":"Follow the corridor",
	"objective_subtitle":"BAIN: Welcome. Before we send you on any jobs, we need to run the ability tests and some calibration. Try moving around. Follow the corridor for now. And hopefully, the interface should show up for you. I left some special help text for you if you get lost.",
	"subtitle_priority":2,
	"subtitle_length":10},
	2:{"objective_name":"Shoot the door",
	"objective_subtitle":"BAIN: Alright, it seems like you can walk just fine. Sorry for how the place looks, we don't have a proper training center yet. Anyway, try equipping a weapon and shoot that wooden door at the end of the room.",
	"subtitle_priority":2,
	"subtitle_length":10},
	3:{"objective_name":"Open the doors",
	"objective_subtitle":"BAIN: I locked this door on purpose this time, but usually you'll be able to open them normally just fine. Shooting it open leaves shooting marks on it that will alert people. Now, time for your first real test: Opening doors. Walk to a door and open it. Simple.",
	"subtitle_priority":2,
	"subtitle_length":15},
	4:{"objective_name":"Enter the next room",
	"objective_subtitle":"BAIN: Nice job. Man it feels really nice to finally see a working android. Now move along to the next room.",
	"subtitle_priority":2,
	"subtitle_length":10},
	5:{"objective_name":"Hostage the manequin",
	"objective_subtitle":"BAIN: Time to start working with people. Hostage this manequin. Don't shoot him. You can't kill him anyway. You don't have enough ammo for that.",
	"subtitle_priority":2,
	"subtitle_length":10},
	6:{"objective_name":"Interrogate the manequin",
	"objective_subtitle":"BAIN: Good. On a real mission, you should always tie your hostages or they'll be trying to escape. Now, interrogate the manequin. You need a code to open that door in front of you.",
	"subtitle_priority":2,
	"subtitle_length":10},
	7:{"objective_name":"Take the disguise",
	"objective_subtitle":"BAIN: Perfect. One more thing. The next area has cameras that will instantly detect you sneaking around. You need a disguise. Knock out the manequin and take his clothes. Don't worry, they're not dirty.",
	"subtitle_priority":2,
	"subtitle_length":15},
	8:{"objective_name":"Sneak past the cameras",
	"objective_subtitle":"BAIN: I think you might be the first bot to pass this test! Lastly, you'll have to sneak past the cameras. Do not get spotted. And don't even think of trying to destroy the cameras.",
	"subtitle_priority":2,
	"subtitle_length":7.5},
	9:{"objective_name":"Escape"},
}

var current_objective: int = 0
var are_cameras_alerted: bool = false

func _ready():
	Game.game_scene = $Objects

	menu_track.stop()
	restart_game()

	update_objective(1)

	$Tutorial.play()

func update_objective(objective: int):
	current_objective = objective
	var cur_objective_dict: Dictionary = objectives[current_objective]

	Game.ui.update_objective(cur_objective_dict["objective_name"])

	if (cur_objective_dict.has("objective_subtitle")):
		Game.ui.update_subtitle(cur_objective_dict["objective_subtitle"],cur_objective_dict["subtitle_priority"],cur_objective_dict["subtitle_length"])

	if (current_objective == 2):
		Game.player_can_shoot = true
	elif (current_objective == 3):
		Game.player_can_interact = true
	elif (current_objective == 7):
		$NPCs/Manequin1.can_knock = true
	elif (current_objective == 8):
		$Objectives/LockedDoor2.can_interact = true
	elif (current_objective == 9):
		$Objectives/Wood_door2.can_interact = true

		if (Savedata.player_stats["is_new"]):
			Game.ui.update_subtitle("Bain: Congratulations! You've successfully completed the tutorial. Now, as I've promised, I'll transfer some money for you. I recommend buying some weapon attachments to make your weapons concealable. Remember that you can always come back here or check out the 'Help' menu.",2,15)
		else:
			Game.ui.update_subtitle("Bain: Alright, that's the end of the tutorial. Feel free to come back here if you forget about something or check out the 'Help' menu.",2,10)

func _on_ObjectiveZone_entered(object):
	if (object.name == "Zone1"):
		update_objective(2)
	elif (object.name == "Zone2"):
		update_objective(3)
	elif (object.name == "Zone3"):
		update_objective(5)
	elif (object.name == "Zone4"):
		for camera in $Cameras.get_children():
			camera.is_disabled = true
			camera.detection_value = 0

		update_objective(9)
	elif (object.name == "Zone5"):
		if (are_cameras_alerted):
			are_cameras_alerted = false
			Game.ui.update_subtitle("BAIN: Now try again. Do not get spotted.",2,5)
			$ObjectiveZones/Zone4/CollisionPolygon2D.set_deferred("disabled",false)

			for camera in $Cameras.get_children():
				camera.is_disabled = false
				camera.is_alerted = false
				camera.is_detecting = false
				camera.get_node("Detection_timer").start()

func _on_object_interaction_finished(object, action):
	if (object.name  == "MetalDoor" && action == "lockpick"):
		Game.ui.update_subtitle("BAIN: See how you couldn't shoot this door to open? Now, the need door won't be easy either. You'll need a special item to open it.",2,7)
	elif (object.name  == "Keycard_blue"):
		Game.ui.update_subtitle("BAIN: This is what you'll need this time. But sometimes, other items might be needed.",2,7)
	elif (object.name  == "LockedDoor" && current_objective < 3):
		update_objective(4)
	elif (object.name == "Manequin1" && action == "disguise"):
		update_objective(8)
	elif (object.name == "Vault2"):
		if (Savedata.player_stats["is_new"]):
			Savedata.player_stats["is_new"] = false
			Savedata.player_stats["money"] = 50000

		$Tutorial.stop()
		Composer.goto_scene(Global.scene_paths["mainmenu"],true,false,0.5,0.5)

func _on_Manequin1_npc_hostaged(object):
	update_objective(6)

func interrogated(object):
	Game.ui.update_popup("You got the door code.",4)
	Game.add_player_inventory_item("vault_code")

	update_objective(7)

func on_Camera_alerted():
	Game.ui.update_subtitle("BAIN: You just got yourself detected. Come back to the area with the Manequin and try again.",2,10)
	are_cameras_alerted = true
	$ObjectiveZones/Zone4/CollisionPolygon2D.set_deferred("disabled",true)

	for camera in $Cameras.get_children():
		camera.is_disabled = true
		camera.detection_value = 0

func restart_game():
	Game.difficulty = 4

	Game.player_weapons[0] = "UZI"
	Game.player_weapons[1] = "M9"
	Game.player_armor = "Suit"
	Game.player_equipment[0][0] = "none"
	Game.player_equipment[0][1] = 0
	Game.player_equipment[1][0] = "none"
	Game.player_equipment[1][1] = 0
	Game.player_attachments["UZI"] = {"barrel":"suppressor1_auto","sight":"","stock":"","magazine":"short_uzi"}
	Game.player_attachments["M9"] = {"barrel":"suppressor2_pistol","sight":"","stock":"","magazine":""}

	Game.can_spawn = false

	Game.max_targets = 3
	Game.current_cops = 0

	Game.stolen_cash = 0
	Game.xp_earned = 0

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
	Game.player_can_interact = false
	Game.player_can_shoot= false
	Game.player_can_melee = false
	Game.player_can_run = true
	Game.player_can_use_equipment = false

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

	Game.handcuffs = 3
	Game.bodybags = 1

	Game.map = self

	var player = player_scene.instance()
	$Player.add_child(player)
	player.global_position = Vector2(256,1024)

	player.health = 100
	player.stamina = 100

	var camera: Camera2D = Game.player.get_node("Player_camera")
	var ground_size: Rect2 = $Ground.get_used_rect()

	camera.limit_top = (ground_size.position.y * 128) + 128
	camera.limit_bottom = (ground_size.end.y * 128) - 128
	camera.limit_left = (ground_size.position.x * 128)
	camera.limit_right = (ground_size.size.x * 128)

	Game.player.add_weapons()

	Game.update_attachments()
	Game.update_armor()


	Game.game_process = true

func _process(delta):
	if (!Game.game_process):
		return

	if (Input.is_action_just_pressed("reset") && current_objective < 9):
		$Tutorial.stop()
		Composer.goto_scene(Global.scene_paths["mainmenu"],true,false,0.5,0.5)
