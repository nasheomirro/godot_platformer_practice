extends Camera2D

const TILE_OFFSET = 1

func _ready():
	var map = get_tree().current_scene.get_node("Map")
	if not map:
		print("map doesn't exists, cannot set camera limits")
	else:
		if not map.is_node_ready():
			await map.ready
		
		var map_limits = map.get_used_rect()
		var map_cellsize = map.tile_set.tile_size
		
		limit_left = (map_limits.position.x + TILE_OFFSET) * map_cellsize.x
		limit_right = (map_limits.end.x - TILE_OFFSET) * map_cellsize.x
		limit_bottom = (map_limits.end.y - TILE_OFFSET) * map_cellsize.y
		
		print(limit_left, limit_right, limit_bottom)
