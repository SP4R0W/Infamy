extends Node2D

export(int,0,4) var cop_amount = 1
export(String, "normal","heavy","shield") var cop_type = "normal"
export var cop_health: float = 25

export var is_active: bool = false
export var delay: float = 2.5 setget delay_set

var first_spawn = true

onready var positions: Array = [
	$One.global_position,
	$Two.global_position,
	$Three.global_position,
	$Four.global_position
]

func _ready():
	$Timer.wait_time = delay
	
func delay_set(new_value):
	delay = new_value
	$Timer.wait_time = new_value
	
func _physics_process(delta):
	if (!is_active || !Game.game_process || !Game.can_spawn || cop_amount == 0):
		return
	
	if ($Timer.time_left <= 0):
		if (first_spawn && cop_type != "shield" && cop_type != "heavy"):
			spawn_cops()
		elif (!first_spawn):
			spawn_cops()
			
		first_spawn = false
			
		$Timer.start()
		

func spawn_cops():
	if (Game.current_cops < 0):
		Game.current_cops = 24
	
	if ((Game.current_cops >= Game.max_cops && cop_type != "heavy") || Game.map.is_wave_break):
		return
	
	for x in range(0,cop_amount):
		if (Game.current_cops >= Game.max_cops && cop_type != "heavy"):
			return
			
		var c
		if (cop_type == "normal"):
			c = Game.scene_objects["cop"].instance()
		elif (cop_type == "shield"):
			c = Game.scene_objects["shield"].instance()
		elif (cop_type == "heavy"):
			c = Game.scene_objects["heavy"].instance()

		c.global_position = positions[x]
		c.health = cop_health
		
		Game.current_cops += 1
		Game.map.get_node("NPCs/Cops").add_child(c)
