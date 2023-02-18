extends Weapon

var modification_offsets: Dictionary = {
	"suppressor1":Vector2(425,-3),
	"suppressor2":Vector2(400,-3),
	"suppressor3":Vector2(335,-3),
	"compensator1":Vector2(350,-3),
	"compensator2":Vector2(350,-3),
	"compensator3":Vector2(365,-3),
	"stock_uzi":Vector2(-245,0)
}

func _ready():
	base_firerate = Global.weapon_base_values[name]["firerate"]
	base_reload_time = Global.weapon_base_values[name]["reload_time"]
	base_empty_reload_time = Global.weapon_base_values[name]["reload_time_empty"]
	base_mag_size = Global.weapon_base_values[name]["magsize"]
	base_ammo_count = Global.weapon_base_values[name]["ammo_count"]
	base_damage = Global.weapon_base_values[name]["damage"]
	base_accuracy = Global.weapon_base_values[name]["accuracy"]
	base_concealment = Global.weapon_base_values[name]["concealment"]
	
	$Melee/MeleeShape.disabled = true
	
	draw_attachments()

func draw_attachments():
	firerate = 60/base_firerate
	reload_time = base_reload_time
	empty_reload_time = base_empty_reload_time
	damage = base_damage

	mag_size = base_mag_size
	ammo_count = base_ammo_count
	accuracy = base_accuracy
	concealment = base_concealment
	
	is_weapon_suppresed = false
	
	var attachments = Game.player_attachments[name]
	
	$Sprite/Barrel_attachment.texture = null
	$Sprite/Stock_attachment.texture = null
	
	if (attachments["barrel"] != ""):
		$Sprite/Barrel_attachment.texture = load(Global.weapon_attachment_paths[attachments["barrel"]])
		$Sprite/Barrel_attachment.offset = modification_offsets[attachments["barrel"]]
		
		damage += Global.attachment_values[attachments["barrel"]]["damage"]
		accuracy += Global.attachment_values[attachments["barrel"]]["accuracy"]
		concealment += Global.attachment_values[attachments["barrel"]]["concealment"]
		
		if (attachments["barrel"].find("suppressor") != -1):
			is_weapon_suppresed = true
		else:
			is_weapon_suppresed = false
			
	if (attachments["sight"] != ""):
		accuracy += Global.attachment_values[attachments["sight"]]["accuracy"]
		concealment += Global.attachment_values[attachments["sight"]]["concealment"]
		
	if (attachments["magazine"] != ""):
		mag_size += Global.attachment_values[attachments["magazine"]]["mag_size"]
		accuracy += Global.attachment_values[attachments["magazine"]]["accuracy"]
		concealment += Global.attachment_values[attachments["magazine"]]["concealment"]
			
	if (attachments["stock"] != ""):
		$Sprite/Stock_attachment.texture = load(Global.weapon_attachment_paths[attachments["stock"]])
		$Sprite/Stock_attachment.offset = modification_offsets[attachments["stock"]]
		
		accuracy += Global.attachment_values[attachments["stock"]]["accuracy"]
		concealment += Global.attachment_values[attachments["stock"]]["concealment"]

	current_mag_size = mag_size
	current_ammo_count = ammo_count

	if (concealment < 8):
		is_weapon_visible = true
	else:
		is_weapon_visible = false
