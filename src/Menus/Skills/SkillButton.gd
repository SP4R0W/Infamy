extends Button

func _ready():
	pass

func _on_SkillButton_mouse_entered():
	Global.skillMenu.show_desc(int(self.name))

func _on_SkillButton_gui_input(event):
	if (event is InputEventMouseButton):
		if (event.is_pressed()):
			if (event.button_index == BUTTON_LEFT):
				Global.skillMenu.buy_skill(int(self.name))
			elif (event.button_index == BUTTON_RIGHT):
				Global.skillMenu.refund_skill(int(self.name))
