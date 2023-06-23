extends Panel

var maps: Dictionary = {
	"bank":"res://src/Game/Maps/bank/blueprint.png"
}

func _ready():
	$Map.texture = load(maps[Game.level])

	show_plan()

func show_plan() -> void:
	$Plan.show()
	$Assets.hide()
	$Gear.hide()
	$Music.hide()

func show_assets() -> void:
	$Plan.hide()
	$Assets.show()
	$Gear.hide()
	$Music.hide()

func show_gear() -> void:
	$Plan.hide()
	$Assets.hide()
	$Gear.show()
	$Music.hide()

func show_music() -> void:
	$Plan.hide()
	$Assets.hide()
	$Gear.hide()
	$Music.show()

func _on_Plan_pressed() -> void:
	show_plan()

func _on_Assets_pressed() -> void:
	show_assets()

func _on_Gear_pressed() -> void:
	show_gear()

func _on_Music_pressed() -> void:
	show_music()
