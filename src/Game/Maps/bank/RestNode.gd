extends Node2D

var available_positions: Dictionary = {}

var positions_rotations: Dictionary = {
	1:45,
	2:-40,
	3:-135,
	4:-225,
	5:180,
	6:180,
	7:180,
	8:180,
	9:-35,
	10:-135,
	11:-90,
	12:0,
	13:180,
	14:180,
	15:0,	
	16:0,
	17:180,
	18:140,
	19:90,
	20:40,
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
