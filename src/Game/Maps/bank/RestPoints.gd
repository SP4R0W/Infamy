extends Node2D

var available_positions: Dictionary = {}

var positions_rotations: Dictionary = {
	1:180,
	2:180,
	3:-45,
	4:-135,
	5:0,
	6:90,
	7:90,
	8:-90,
	9:-90,
	10:90,
	11:-90,
	12:90,
	13:90,	
	14:90,
	15:-90,
	16:-90,
	17:-90,
	18:45,
}

func _ready():
	for point in get_children():
		available_positions[int(point.name)] = true
		
func set_locked(pos: int):
	available_positions[pos] = false
	
func set_free(pos: int):
	available_positions[pos] = true

func get_random_free_pos(last_pos: int) -> Array:
	var is_free_place: bool = false
	
	if true in available_positions.values():
		is_free_place = true
		
	if (!is_free_place):
		return []
	else:
		var num: int = last_pos
		while true:
			num = rand_range(1,available_positions.size())
			if (num != last_pos):
				if (available_positions[num]):
					return [get_child(num - 1), num]
					
	return []
