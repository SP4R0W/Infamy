extends Node

# This file stores data loaded from save file and manages the function for saving, loading and modifying save data.

var player_stats: Dictionary = {
	"money":0,
	"total_xp":0,
	"cur_xp":0,
	"needed_xp":0,
	"level":0,
	"preffered_loadout":"1",
	"is_new":true
}

var player_loadouts: Dictionary = {
	"1":{"primary":"UZI",
	"attachments_primary":{
		"barrel":"",
		"sight":"",
		"magazine":"",
		"stock":""
	},
	"secondary":"M9",
	"attachments_secondary":{
		"barrel":"",
		"sight":"",
		"magazine":"",
		"stock":""
	},
	"armor":"Suit",
	"equipment1":"none",
	"equipment2":"none"},
	
	"2":{"primary":"UZI",
	"attachments_primary":{
		"barrel":"",
		"sight":"",
		"magazine":"",
		"stock":""
	},
	"secondary":"M9",
	"attachments_secondary":{
		"barrel":"",
		"sight":"",
		"magazine":"",
		"stock":""
	},
	"armor":"Suit",
	"equipment1":"none",
	"equipment2":"none"},
	
	"3":{"primary":"UZI",
	"attachments_primary":{
		"barrel":"",
		"sight":"",
		"magazine":"",
		"stock":""
	},
	"secondary":"M9",
	"attachments_secondary":{
		"barrel":"",
		"sight":"",
		"magazine":"",
		"stock":""
	},
	"armor":"Suit",
	"equipment1":"none",
	"equipment2":"none"},
}

var skill_loadouts = {
	"1":{
		"skill_points":0,
		"mastermind":
		[
			"none", # Tier 4, Skill 1
			"none", # Tier 4, Skill 2
			"none", # Tier 4, Skill 3
			"none", # Tier 3, Skill 1
			"none", # Tier 3, Skill 2
			"none", # Tier 3, Skill 3
			"none", # Tier 2, Skill 1
			"none", # Tier 2, Skill 2
			"none", # Tier 2, Skill 3
			"none", # Tier 1, Skill 1
			"none", # Tier 1, Skill 2
			"none", # Tier 1, Skill 3
		],
		"commando":
		[
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
		],
		"engineer":
		[
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
		],
		"infiltrator":
		[
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
		],
	},
	"2":{
		"skill_points":0,
		"mastermind":
		[
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
		],
		"commando":
		[
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
		],
		"engineer":
		[
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
		],
		"infiltrator":
		[
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
		],
	},
	"3":{
		"skill_points":0,
		"mastermind":
		[
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
		],
		"commando":
		[
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
		],
		"engineer":
		[
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
		],
		"infiltrator":
		[
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
			"none",
		],
	}
}

var owned_attachments: Dictionary = {
	"suppressor1_pistol":0,
	"suppressor2_pistol":0,
	"suppressor3_pistol":0,
	"compensator1_pistol":0,
	"compensator2_pistol":0,
	"compensator3_pistol":0,
	"reflex":0,
	"holo":0,
	"acog":0,
	"extended_m9":0,
	"extended_uzi":0,
	"short_uzi":0,
	"stock_uzi":0,
}

var owned_weapons: Dictionary = {
	"UZI":true,
	"M9":true
}

var player_settings = {
	"master_volume":100,
	"music_volume":100,
	"sfx_volume":100,
	"dead_bodies":true,
	"subtitles":true,
	"fps":false,
	"timers":true,
	"auto_reload":true,
	"im_a_cheater":false,
}

func load_data():
	var dir = Directory.new()
	var file = File.new()

	# checks for whether or not the dictionary and file exist
	if (!dir.dir_exists("user://Save")):
		create_new_save()
		return

	if (!file.file_exists("user://Save/savedata.save")):
		create_new_save()
		return
	
	file.open_encrypted_with_pass("user://Save/savedata.save",File.READ,"P8tle7P0UH")
	
	var data = parse_json(file.get_as_text()) as Dictionary
	
	# load the data

	for key in data["player_stats"].keys():
		player_stats[key] = data["player_stats"][key]
		
	for key in data["player_loadouts"].keys():
		player_loadouts[key] = data["player_loadouts"][key]
		
	for key in data["skill_loadouts"].keys():
		skill_loadouts[key] = data["skill_loadouts"][key]
		
	for key in data["owned_attachments"].keys():
		owned_attachments[key] = data["owned_attachments"][key]
		
	for key in data["owned_weapons"].keys():
		owned_weapons[key] = data["owned_weapons"][key]
		
	for key in data["player_settings"].keys():
		player_settings[key] = data["player_settings"][key]

	if (player_settings["im_a_cheater"]):
		reset_progress()

func save_data():
	var dir = Directory.new()
	var file = File.new()

	# checks for whether or not the dictionary and file exist

	if (!dir.dir_exists("user://Save")):
		create_new_save()
		return

	if (!file.file_exists("user://Save/savedata.save")):
		create_new_save()
		return
		
	file.open_encrypted_with_pass("user://Save/savedata.save",File.WRITE,"P8tle7P0UH")
	
	# save data to a file
	file.store_line(to_json(get_save_dict()))
	
func create_new_save():
	var dir = Directory.new()
	var file = File.new()
	
	var save_folder = dir.open("user://Save")
	
	# try creating a new directory and report errors if it fails
	
	if (!dir.dir_exists("user://Save")):
		var success_dir = dir.make_dir("user://Save")
		if (success_dir != OK):
			Global.root.warning_panel.show()
			Global.root.warning_panel.get_node("VBoxContainer/Message").text = "Couldn't create Directory."
			Global.root.warning_panel.get_node("VBoxContainer/Error").text = "Error code: " + str(success_dir)
			return
	
	# try creating a new file and report errors if it fails
	
	var success_file = file.open_encrypted_with_pass("user://Save/savedata.save",File.WRITE,"P8tle7P0UH")
	if (success_file != OK):
		Global.root.warning_panel.show()
		Global.root.warning_panel.get_node("VBoxContainer/Message").text = "Couldn't open file."
		Global.root.warning_panel.get_node("VBoxContainer/Error").text = "Error code: " + str(success_file)
		return
		
	# create new save data with stats back to default
	file.store_line(to_json(get_save_dict()))

func get_save_dict() -> Dictionary:
	# create a wiped out save
	
	var dict = {
		"player_stats":{},
		"player_loadouts":{},
		"skill_loadouts":{},
		"owned_attachments":{},
		"owned_weapons":{},
		"player_settings":{}
	}
	
	for key in player_stats.keys():
		dict["player_stats"][key] = player_stats[key]
	
	for key in player_loadouts.keys():
		dict["player_loadouts"][key] = player_loadouts[key]
		
	for key in skill_loadouts.keys():
		dict["skill_loadouts"][key] = skill_loadouts[key]
		
	for key in owned_attachments.keys():
		dict["owned_attachments"][key] = owned_attachments[key]
		
	for key in owned_weapons.keys():
		dict["owned_weapons"][key] = owned_weapons[key]
		
	for key in player_settings.keys():
		dict["player_settings"][key] = player_settings[key]
	
	return dict

func reset_progress():
	# reset data back to default values
	
	for key in player_stats.keys():
		if (key == "preffered_loadout"):
			player_stats[key] = "1"
		elif (key == "is_new"):
			player_stats[key] = true
		else:
			player_stats[key] = 0
			
	for key in player_loadouts.keys():
		for key2 in player_loadouts[key].keys():
			if (key2 == "primary"):
				player_loadouts[key][key2] = "UZI"
			elif (key2 == "secondary"):
				player_loadouts[key][key2] = "M9"
			elif (key2 == "armor"):
				player_loadouts[key][key2] = "Suit"
			elif (key2 == "equipment1"):
				player_loadouts[key][key2] = "none"
			elif (key2 == "equipment2"):
				player_loadouts[key][key2] = "none"
			else:
				for attachment in player_loadouts[key][key2].keys():
					player_loadouts[key][key2][attachment] = ""
				
			
	for key in skill_loadouts.keys():
		for key2 in skill_loadouts[key].keys():
			if (key2 == "skill_points"):
				skill_loadouts[key][key2] = 0
			else:
				for x in range(0,skill_loadouts[key][key2].size()):
					skill_loadouts[key][key2][x] = "none"
			
	for key in owned_attachments.keys():
		owned_attachments[key] = 0
			
	for key in owned_weapons.keys():
		if (key == "UZI" || key == "M9"):
			owned_weapons[key] = true
		else:
			owned_weapons[key] = false
			
	player_settings["im_a_cheater"] = false
	
	# save after cleaning	
	save_data()
