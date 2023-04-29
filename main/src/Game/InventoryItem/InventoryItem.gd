extends Panel

onready var panel: PanelContainer = $PanelContainer
onready var image: TextureRect = $Image
onready var label: Label = $PanelContainer/Display

export var item: String = "" setget set_item

func set_item(new_value):
	item = new_value
	image.texture = load(Global.item_textures[item])
	label.text = Global.item_labels[item]

func _ready():
	panel.hide()


func _on_InventoryItem_mouse_entered():
	panel.show()


func _on_InventoryItem_mouse_exited():
	panel.hide()
