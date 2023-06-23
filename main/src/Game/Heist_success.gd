extends Panel

var titles: Dictionary = {
	"bank":"Downtown Hit",
}

var praises = [
	"Excellent work! They don't even know what hit em.",
	"Beautifully done. Expect more jobs from me soon.",
	"Amazing job! I don't think even I could perform as well.",
	"Textbook execution. Enjoy your cut. You deserve it.",
	"I knew I'm a master of intelligent AI. Nice work."
]

func draw_success():
	Savedata.player_stats["money"] += (Game.stolen_cash - Game.killed_civilians_penalty)
	Savedata.player_stats["cur_xp"] += Game.xp_earned + (Game.xp_earned * Game.difficulty)

	if (Savedata.player_stats["money"] > 999_999_999):
		Savedata.player_stats["money"] = 999_999_999

	Global.calculate_levels(Savedata.player_stats["cur_xp"])

	$Heist_title.text = titles[Game.level] + ": " + Game.difficulty_names[Game.difficulty] + " - SUCCESS"
	$Praise.text = praises[randi() % praises.size()]

	$HSplitContainer/Money/contract_value.text = "Contract: " + Global.format_str_commas(Global.contract_values[Game.level]["rewards_mon"] + (Global.contract_values[Game.level]["rewards_mon_bonus"] * Game.difficulty)) + "$"
	$HSplitContainer/Money/loot_value.text = "Stolen Loot: " + Global.format_str_commas(Game.stolen_cash_bags + Game.stolen_cash_loose) + "$"
	$HSplitContainer/Money/cleaner_value.text = "Cleaner costs: -" + Global.format_str_commas(Game.killed_civilians_penalty) + "$"
	$HSplitContainer/Money/total_value.text = "Total payday: " + Global.format_str_commas(Game.stolen_cash - Game.killed_civilians_penalty) + "$"
	$HSplitContainer/Money/account.text = "Your account: " + Global.format_str_commas(Savedata.player_stats["money"]) + "$"

	var xp = Global.contract_values[Game.level]["rewards_xp"] + (Global.contract_values[Game.level]["rewards_xp_bonus"] * Game.difficulty)

	$HSplitContainer/XP/contract_value2.text = "Contract: " + Global.format_str_commas(xp + (xp * Game.difficulty))
	$HSplitContainer/XP/stealth_value.text = "Stealth: " + Global.format_str_commas(Game.xp_earned_stealth + (Game.xp_earned_stealth * Game.difficulty))
	$HSplitContainer/XP/bag_value.text = "Bags stolen: " + Global.format_str_commas(Game.xp_earned_bags + (Game.xp_earned_bags * Game.difficulty))
	$HSplitContainer/XP/total_value.text = "Total XP earned: " + Global.format_str_commas(Game.xp_earned + (Game.xp_earned * Game.difficulty))
	$HSplitContainer/XP/level.text = "Your current level is: " + str(Savedata.player_stats["level"])

