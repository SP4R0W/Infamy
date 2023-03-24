extends Node2D

var skill_descriptions = [
	[
		"'Tank'\n\nBASIC:\n4 Skill points\nYour health is now increased by 25%.\n\nUPGRADED:\n8 Skill Points\nYour health is now increased by 50%.",
		"'Hostage Taker'\n\nBASIC:\n4 Skill points\nEvery 5 seconds, you will be healed for 2.5% of your health if you have at least one hostage.\n\nUPGRADED:\n8 Skill Points\nYou will now be healed for 5% and you also receive an additional 25% stamina boost.",
		"'White Death'\n\nBASIC:\n4 Skill points\nIf you a kill a cop with a sniper, all other people in a 10m range will be dealt 50% of the damage dealt.\n\nUPGRADED:\n8 Skill Points\nYou will now deal 100% of the damage dealt.",
		"'Sharer'\n\nBASIC:\n3 Skill points\nYou will now for 50% of your total health from a First Aid Kit.\n\nUPGRADED:\n6 Skill Points\nYour First Aid Kits will now heal you for 85% of your total health.",
		"'Controller'\n\nBASIC:\n3 Skill points\nHostages will try to escape less frequently.\n\nUPGRADED:\n6 Skill Points\nFor each hostage you have, you gain 1,5% damage reduction (up to 15% total)",
		"'Desperado'\n\nBASIC:\n3 Skill points\nKilling 4 cops in 6 seconds with a sniper rifle will grant you a 15% faster next reload.\n\nUPGRADED:\n6 Skill Points\nKilling 3 cops in 6 seconds with a sniper will also refill a bullet.",
		"'Combat Medic'\n\nBASIC:\n3 Skill points\nYou can now carry 4 First Aid Kits.\n\nUPGRADED:\n4 Skill Points\nYou can now carry 6 First Aid Kits.",
		"'Intimidator'\n\nBASIC:\n3 Skill points\nYour range of taking hostages is doubled.\n\nUPGRADED:\n4 Skill Points\nYou now have a 50% chance of finding handcuffs in ammo boxes.",
		"'Hunter'\n\nBASIC:\n3 Skill points\nYour snipers will now deal full damage to shields.\n\nUPGRADED:\n4 Skill Points\nShields and heavies will be dealt 100% more damage with snipers.",
		"'Overdose'\n\nBASIC:\n1 Skill point\nAfter healing, you move 25% faster for 10s.\n\nUPGRADED:\n3 Skill Points\nAfter healing, you will also gain 25% damage reduction for 10s.",
		"'Cable Guy'\n\nBASIC:\n1 Skill point\nYou can now carry 6 cable ties.\n\nUPGRADED:\n3 Skill Points\nCable tie bag capacity will be doubled. You will tie people 100% faster.",
		"'Sharpshooter'\n\nBASIC:\n1 Skill point\nYour accuracy with snipers is improved by 10%.\n\nUPGRADED:\n3 Skill Points\nAccuracy reduction when moving is removed.",
	],
	[
		"'Fully Loaded'\n\nBASIC:\n4 Skill points\nYour magazine capacity is increased by 25%.\n\nUPGRADED:\n8 Skill Points\nYour total ammo is increased by 50%.",
		"'Unbreakable'\n\nBASIC:\n4 Skill points\nYou unlock the Full Body Armor Kit.\n\nUPGRADED:\n8 Skill Points\nFor each shield or heavy killed, you gain 2.5% armor back. This has a cooldown of 3s.",
		"'Golden Scout'\n\nBASIC:\n4 Skill points\nKilling 2 enemies in 2s with a shotgun grants you a 50% damage boost for shotguns that lasts 20s.\n\nUPGRADED:\n8 Skill Points\nDamage boost now applies to all other weapons.",
		"'Well Stocked'\n\nBASIC:\n3 Skill points\nYou can now carry 3 Ammo Kits.\n\nUPGRADED:\n6 Skill Points\nYou can now carry 5 Ammo Kits.",
		"'Heavy Lifter'\n\nBASIC:\n3 Skill points\nYou take 50% less damage when interacting.\n\nUPGRADED:\n6 Skill Points\nYour armor is now 50% less heavy.",
		"'Crackdown'\n\nBASIC:\n3 Skill points\nYour shotguns will now fire 2x more pellets.\n\nUPGRADED:\n6 Skill Points\nShotgun damage is doubled.",
		"'Bulletstorm'\n\nBASIC:\n3 Skill points\nYour Ammo Kit will refill both of your weapons ammo.\n\nUPGRADED:\n4 Skill Points\nYou gain 10s of infinite ammo after using Ammo Kit.",
		"'Portier'\n\nBASIC:\n3 Skill points\nYou bag loot 50% faster.\n\nUPGRADED:\n4 Skill Points\nYour loot bags are now 50% less heavy.",
		"'Fast Hands'\n\nBASIC:\n3 Skill points\nYou reload shotguns 15% faster.\n\nUPGRADED:\n4 Skill Points\nYou can now load 2 shells for shotguns at once.",
		"'Donor'\n\nBASIC:\n1 Skill point\nYou collect 20% more ammo from ammo boxes.\n\nUPGRADED:\n3 Skill Points\nEvery 10th cop you kill will spawn 2 ammo boxes instead of 1.",
		"'Heavy'\n\nBASIC:\n1 Skill point\nYour armor Absorption value is increased by 10%.\n\nUPGRADED:\n3 Skill Points\nYour armor Strength value is decreased by 2.5.",
		"'Scout'\n\nBASIC:\n1 Skill point\nYour shotguns will now deal 10% more damage.\n\nUPGRADED:\n3 Skill Points\nYour shotguns will now deal 25% more damage.",
	],
	[
		"'Deep Pockets'\n\nBASIC:\n4 Skill points\nYou can now carry two equipments, however the second one only has 50% of its capacity.\n\nUPGRADED:\n8 Skill Points\nThe capacity penalty is now removed.",
		"'Maniac'\n\nBASIC:\n4 Skill points\nYou can penetrate shields with automatic weapons.\n\nUPGRADED:\n8 Skill Points\nYou can penetrate shields with any weapon. You gain extra 25% damage reduction",
		"'Push It'\n\nBASIC:\n4 Skill points\nIf your health is below 25%, you will start regenerating 1.5% armor and health with each enemy that you kill till you reach 25% again. This has a delay of 2s.\n\nUPGRADED:\n8 Skill Points\nThe effect now starts at below 50% health and you gain 2.5% of health and armor.",
		"'Good Tools'\n\nBASIC:\n3 Skill points\nYour drills are 50% less noisy.\n\nUPGRADED:\n6 Skill Points\nYour drills are now fully silent.",
		"'Breacher'\n\nBASIC:\n3 Skill points\nYou can use C4 on safes now.\n\nUPGRADED:\n6 Skill Points\nYour C4 will emit 85% less noise when used on objects.",
		"'Lock'n Load\n\nBASIC:\n3 Skill points\nKilling 2 cops in 2s with an automatic weapon grants you 50% faster next reload.\n\nUPGRADED:\n6 Skill Points\nYou can reload while sprinting.",
		"'Quick Fix'\n\nBASIC:\n3 Skill points\nYou fix drills 50% faster.\n\nUPGRADED:\n4 Skill Points\nYour drills have a 50% chance to auto repair after 5s when they break.",
		"'Demoman'\n\nBASIC:\n3 Skill points\nYou can now carry 6 C4s.\n\nUPGRADED:\n4 Skill Points\nYou can now carry 9 C4s.",
		"'Oppressor'\n\nBASIC:\n3 Skill points\nYou get 10 more rounds in the mag for your automatic weapons.\n\nUPGRADED:\n4 Skill Points\nHeavies take 2x damage from automatic weapons.",
		"'Drill Expert'\n\nBASIC:\n1 Skill point\nYour drills are now 10% faster.\n\nUPGRADED:\n3 Skill Points\nYour drills are now 20% faster.",
		"'B Safety'\n\nBASIC:\n1 Skill point\nYour C4s have a bigger radius for checking targets and explosion.\n\nUPGRADED:\n3 Skill Points\nYour C4 deals 50% more damage.",
		"'Tension'\n\nBASIC:\n1 Skill point\nYour firerate with automatic weapons is increased by 25%.\n\nUPGRADED:\n3 Skill Points\nYou deal 10% more damage with automatic weapons.",
	],
	[
		"'Expert Jammer'\n\nBASIC:\n4 Skill points\nECM duration is now 15s.\n\nUPGRADED:\n8 Skill Points\nYou can carry 4 ECMs.",
		"'Locksmith'\n\nBASIC:\n4 Skill points\nYou lockpick stuff 100% faster.\n\nUPGRADED:\n8 Skill Points\nYou can now lockpick safes.",
		"'Sneaky Bastard'\n\nBASIC:\n4 Skill points\nWhen killing an enemy with stun active, you will now heal for 2.5% of your health.\n\nUPGRADED:\n8 Skill Points\nYou gain 3x chance to dodge when stun is active. You also gain 50% damage reduction.",
		"'Disruptor'\n\nBASIC:\n3 Skill points\nYou can now loop cameras. They will remain disabled for 10s.\n\nUPGRADED:\n6 Skill Points\nCameras will now remain disabled for 25s.",
		"'Hacker'\n\nBASIC:\n3 Skill points\nYou can now unlock locked doors with ECMs.\n\nUPGRADED:\n6 Skill Points\nYou can now hack computers.",
		"'Hitman'\n\nBASIC:\n3 Skill points\nSilenced weapons now deal 15% more damage.\n\nUPGRADED:\n6 Skill Points\nSilenced weapons now deal 30% more damage.",
		"'Cleaner'\n\nBASIC:\n3 Skill points\nYou bag bodies 50% faster.\n\nUPGRADED:\n4 Skill Points\nYou can now carry 2 Body Bags.",
		"'Blending In'\n\nBASIC:\n3 Skill points\nTaking disguise is now 50% faster.\n\nUPGRADED:\n4 Skill Points\nYour disguise is now 35% more effective.",
		"'Contraband'\n\nBASIC:\n3 Skill points\nEach silenced weapon gets an additional 1 concealment point.\n\nUPGRADED:\n4 Skill Points\nEach silenced weapon now gets an additional 2 concealment points.",
		"'Overdrive'\n\nBASIC:\n1 Skill point\nYou can carry 2 ECMs now.\n\nUPGRADED:\n3 Skill Points\nDuration of an ECM is now 10s.",
		"'Lighting Bolt'\n\nBASIC:\n1 Skill point\nYou move and sprint 25% faster.\n\nUPGRADED:\n3 Skill Points\nYou get 25% more stamina.",
		"'Silenced Expert'\n\nBASIC:\n1 Skill point\nSilenced weapons have now 10% more accuracy.\n\nUPGRADED:\n3 Skill Points\nSilenced weapons have now 20% more accuracy.",
	]
]

var skill_prices = [
	{"basic":4,"upgraded":8},
	{"basic":4,"upgraded":8},
	{"basic":4,"upgraded":8},
	{"basic":3,"upgraded":6},
	{"basic":3,"upgraded":6},
	{"basic":3,"upgraded":6},
	{"basic":3,"upgraded":4},
	{"basic":3,"upgraded":4},
	{"basic":3,"upgraded":4},
	{"basic":1,"upgraded":3},
	{"basic":1,"upgraded":3},
	{"basic":1,"upgraded":3},
]

var tiers_unlocked = {
	"mastermind":{
		2: false,
		3: false,
		4: false,
	},
	"commando":{
		2: false,
		3: false,
		4: false,
	},
	"engineer":{
		2: false,
		3: false,
		4: false,
	},
	"infiltrator":{
		2: false,
		3: false,
		4: false,
	}
}

var skills_spent = {
	"mastermind":0,
	"commando":0,
	"engineer":0,
	"infiltrator":0,
}

var tier2SkillsNeeded = 4
var tier3SkillsNeeded = 14
var tier4SkillsNeeded = 26

onready var menu_track: AudioStreamPlayer = Global.root.get_node("menu")

var color_none = Color(1,1,1)
var color_basic = Color(115.0/255.0,150.0/255.0,188.0/255.0)
var color_upgrade = Color(10.0/255.0,108.0/255.0,215.0/255.0)

var current_loadout = Savedata.player_stats["preffered_loadout"]
var current_tab = 0

onready var skill_tabs = [
	$Control/CanvasLayer/Skill_panel/Mastermind/GridContainer,
	$Control/CanvasLayer/Skill_panel/Commando/GridContainer,
	$Control/CanvasLayer/Skill_panel/Engineer/GridContainer,
	$Control/CanvasLayer/Skill_panel/Infiltrator/GridContainer,
]

onready var skill_tab_names = [
	"mastermind",
	"commando",
	"engineer",
	"infiltrator"
]

func _ready():
	Global.skillMenu = self
	
	redraw_skills()
	
func _on_Skill_panel_tab_changed(tab):
	current_tab = tab
	redraw_skills()
	
func set_tiers():
	var skill_tab = skill_tab_names[current_tab]
	skills_spent[skill_tab] = 0
	
	var skill_set = Savedata.skill_loadouts[current_loadout][skill_tab]
	for j in range(11,-1,-1):
		var skill = skill_set[j]
		if (skill != "none"):
			skills_spent[skill_tab] += skill_prices[j][skill]
			if (skill == "upgraded"):
				skills_spent[skill_tab] += skill_prices[j]["basic"]
		
		if (skills_spent[skill_tab] >= tier2SkillsNeeded):
			tiers_unlocked[skill_tab][2] = true
		else:
			tiers_unlocked[skill_tab][2] = false
				
		if (skills_spent[skill_tab] >= tier3SkillsNeeded):
			tiers_unlocked[skill_tab][3] = true
		else:
			tiers_unlocked[skill_tab][3] = false
				
		if (skills_spent[skill_tab] >= tier4SkillsNeeded):
			tiers_unlocked[skill_tab][4] = true
		else:
			tiers_unlocked[skill_tab][4] = false
	
func redraw_skills():
	set_tiers()	
	
	$Control/CanvasLayer/VBoxContainer/Title.text = "Skill loadout (" + str(current_loadout) + "):"
	$Control/CanvasLayer/Panel/CenterContainer/Points.text = "Skill points: " + str(Savedata.skill_loadouts[current_loadout]["skill_points"])

	for skill_btn in skill_tabs[current_tab].get_children():
		var skill_variant = Savedata.skill_loadouts[current_loadout][skill_tab_names[current_tab]][int(skill_btn.name) - 1]
		if (skill_variant == "none"):
			skill_btn.add_color_override("font_color",color_none)
			skill_btn.add_color_override("font_color_pressed",color_none)
			skill_btn.add_color_override("font_color_disabled",color_none)
			skill_btn.add_color_override("font_color_focus",color_none)
			skill_btn.add_color_override("font_color_hover",color_none)
		elif (skill_variant == "basic"):
			skill_btn.add_color_override("font_color_hover",color_basic)
			skill_btn.add_color_override("font_color_disabled",color_basic)
			skill_btn.add_color_override("font_color_focus",color_basic)
			skill_btn.add_color_override("font_color_pressed",color_basic)
			skill_btn.add_color_override("font_color",color_basic)
		elif (skill_variant == "upgraded"):
			skill_btn.add_color_override("font_color_pressed",color_upgrade)
			skill_btn.add_color_override("font_color_hover",color_upgrade)
			skill_btn.add_color_override("font_color_disabled",color_upgrade)
			skill_btn.add_color_override("font_color_focus",color_upgrade)
			skill_btn.add_color_override("font_color",color_upgrade)
	
func show_desc(index):
	var skill_tab = skill_tab_names[current_tab]
	
	var desc = skill_descriptions[current_tab][index-1]
	$Control/CanvasLayer/Skill_desc/VBoxContainer/Desc.text = desc
	
	if (index <= 3):
		if (!tiers_unlocked[skill_tab][4]):
			var needed = tier4SkillsNeeded - skills_spent[skill_tab]
			$Control/CanvasLayer/Skill_desc/VBoxContainer/Locked.text = "Tier 4 skills are locked. You need to spend another {left} skill points to unlock Tier 4.".format({"left":needed})
		else:
			$Control/CanvasLayer/Skill_desc/VBoxContainer/Locked.text = ""
	elif (index > 3 && index <= 6):
		if (!tiers_unlocked[skill_tab][3]):
			var needed = tier3SkillsNeeded - skills_spent[skill_tab]
			$Control/CanvasLayer/Skill_desc/VBoxContainer/Locked.text = "Tier 3 skills are locked. You need to spend another {left} skill points to unlock Tier 3.".format({"left":needed})	
		else:
			$Control/CanvasLayer/Skill_desc/VBoxContainer/Locked.text = ""
	elif (index > 6 && index <= 9):
		if (!tiers_unlocked[skill_tab][2]):
			var needed = tier2SkillsNeeded - skills_spent[skill_tab]
			$Control/CanvasLayer/Skill_desc/VBoxContainer/Locked.text = "Tier 2 skills are locked. You need to spend another {left} skill points to unlock Tier 2.".format({"left":needed})
		else:
			$Control/CanvasLayer/Skill_desc/VBoxContainer/Locked.text = ""
	else:
		$Control/CanvasLayer/Skill_desc/VBoxContainer/Locked.text = ""

func buy_skill(index):
	var skill_tab = skill_tab_names[current_tab]
	var skill = Savedata.skill_loadouts[current_loadout][skill_tab][index - 1]
	var skill_points = Savedata.skill_loadouts[current_loadout]["skill_points"]
	var price 
	
	if (skill == "none"):
		price = skill_prices[index-1]["basic"]
	elif (skill == "basic"):
		price = skill_prices[index-1]["upgraded"]
	else:
		$Wrong.play()
		return
	
	if (index <= 3):
		if (!tiers_unlocked[skill_tab][4]):
			$Wrong.play()
			return
	elif (index > 3 && index <= 6):
		if (!tiers_unlocked[skill_tab][3]):
			$Wrong.play()
			return
	elif (index > 6 && index <= 9):
		if (!tiers_unlocked[skill_tab][2]):
			$Wrong.play()
			return
	
	if (skill_points >= price && skill != "upgraded"):
		$Buy.play()
		Savedata.skill_loadouts[current_loadout]["skill_points"] -= price
		
		if (skill == "none"):
			Savedata.skill_loadouts[current_loadout][skill_tab][index - 1] = "basic"
		elif (skill == "basic"):
			Savedata.skill_loadouts[current_loadout][skill_tab][index - 1] = "upgraded"
	else:
		$Wrong.play()
		
	redraw_skills()
	
func refund_skill(index):
	var skill_tab = skill_tab_names[current_tab]
	
	var skills = Savedata.skill_loadouts[current_loadout][skill_tab]
	var skill = Savedata.skill_loadouts[current_loadout][skill_tab][index - 1]
	var price 
	
	if (skill != "none"):
		price = skill_prices[index-1][skill]
	else:
		$Wrong.play()
		return
		
	var temp_skillpoints
	var real_index = index - 1
	
	# Check for tier 3 skills if you own tier 4 skills
	if (real_index == 3 || real_index == 4 || real_index == 5):
		temp_skillpoints = (skills_spent[skill_tab]) - price
		
		temp_skillpoints -= subtract_skill_points(0,3)
		
		if (tiers_unlocked[skill_tab][4] && temp_skillpoints < tier4SkillsNeeded):
			if (skills[0] != "none" || skills[1] != "none" || skills[2] != "none"):
				$Wrong.play()
				return
	# Check for tier 2 skills if you own tier 3 & tier 4 skills
	elif (real_index == 6 || real_index == 7 || real_index == 8):
		temp_skillpoints = (skills_spent[skill_tab]) - price
		
		temp_skillpoints -= subtract_skill_points(0,3)
		
		if (tiers_unlocked[skill_tab][4] && temp_skillpoints < tier4SkillsNeeded):
			if (skills[0] != "none" || skills[1] != "none" || skills[2] != "none"):
				$Wrong.play()
				return
				
		temp_skillpoints -= subtract_skill_points(3,6)
		
		if (tiers_unlocked[skill_tab][3] && temp_skillpoints < tier3SkillsNeeded):
			if (skills[3] != "none" || skills[4] != "none" || skills[5] != "none"):
				$Wrong.play()
				return
	# Check for tier 1 skills if you own tier 2,3 & 4 skills
	elif (real_index == 9 || real_index == 10 || real_index == 11):
		temp_skillpoints = (skills_spent[skill_tab]) - price
		
		temp_skillpoints -= subtract_skill_points(0,3)

		if (tiers_unlocked[skill_tab][4] && temp_skillpoints < tier4SkillsNeeded):
			if (skills[0] != "none" || skills[1] != "none" || skills[2] != "none"):
				$Wrong.play()
				return
				
		temp_skillpoints -= subtract_skill_points(3,6)
		
		if (tiers_unlocked[skill_tab][3] && temp_skillpoints < tier3SkillsNeeded):
			if (skills[3] != "none" || skills[4] != "none" || skills[5] != "none"):
				$Wrong.play()
				return
				
		temp_skillpoints -= subtract_skill_points(6,9)
		
		if (tiers_unlocked[skill_tab][2] && temp_skillpoints < tier2SkillsNeeded):
			if (skills[6] != "none" || skills[7] != "none" || skills[8] != "none"):
				$Wrong.play()
				return

	if (skill != "none"):
		Savedata.skill_loadouts[current_loadout]["skill_points"] += price
		if (skill == "upgraded"):
			Savedata.skill_loadouts[current_loadout][skill_tab][index - 1] = "basic"
		elif (skill == "basic"):
			Savedata.skill_loadouts[current_loadout][skill_tab][index - 1] = "none"
	else:
		$Wrong.play()
		
	redraw_skills()
	
func subtract_skill_points(start: int, end: int) -> int:
	var skill_points = 0
	var skill_tab = skill_tab_names[current_tab]
	var skills = Savedata.skill_loadouts[current_loadout][skill_tab]
	
	for x in range(start,end):
		if (skills[x] == "basic"):
			skill_points += skill_prices[x]["basic"]
		elif (skills[x] == "upgraded"):
			skill_points += skill_prices[x]["basic"]
			skill_points += skill_prices[x]["upgraded"]
		else:
			continue
				
	return skill_points

func _on_Menu_btn_pressed():
	Game.check_skills()
	Savedata.save_data()
	Composer.goto_scene(Global.scene_paths["mainmenu"],true,true,0.5,0.5,menu_track)


func _on_1_btn_pressed():
	current_loadout = "1"
	redraw_skills()
	
	Game.player_skills = Savedata.skill_loadouts[str(current_loadout)]

func _on_2_btn_pressed():
	current_loadout = "2"
	redraw_skills()
	
	Game.player_skills = Savedata.skill_loadouts[str(current_loadout)]

func _on_3_btn_pressed():
	current_loadout = "3"
	redraw_skills()
	
	Game.player_skills = Savedata.skill_loadouts[str(current_loadout)]
