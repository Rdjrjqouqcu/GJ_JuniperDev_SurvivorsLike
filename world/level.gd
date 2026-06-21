extends Node2D
class_name Level

static var instance: Level

var big_tiles: Dictionary[Vector2i, BigTile] = {}
func _grid_allocate_children(c: Dictionary[Vector2i, Node]) -> void:
	for key in c:
		big_tiles[key] = c[key] as BigTile

func _flatten_tile_grid() -> Array[Array]:
	var flattened: Array[Array] = []
	for i in range(7*2):
		var a = []
		for j in range(7*2):
			a.append(null)
		flattened.append(a)
	for key in big_tiles:
		var t = big_tiles[key]
		flattened[key.x * 2][key.y * 2] = t.subtiles[0]
		flattened[key.x * 2][key.y * 2 + 1] = t.subtiles[1]
		flattened[key.x * 2 + 1][key.y * 2] = t.subtiles[2]
		flattened[key.x * 2 + 1][key.y * 2 + 1] = t.subtiles[3]
	return flattened

func _reset_initial_powered(flattened: Array[Array]) -> void:
	for row in flattened:
		for t: Tile in row:
			t.is_powered = false
	flattened[6][6].update_connections(true, true, true, true)
	flattened[6][7].update_connections(true, true, true, true)
	flattened[7][6].update_connections(true, true, true, true)
	flattened[7][7].update_connections(true, true, true, true)
	flattened[6][6].is_powered = true
	flattened[6][7].is_powered = true
	flattened[7][6].is_powered = true
	flattened[7][7].is_powered = true

func recalc_paths() -> void:
	if big_tiles.is_empty():
		return
	# Array[Array[Tile]]
	var flattened: Array[Array] = _flatten_tile_grid()
	_reset_initial_powered(flattened)

	var powering_queue: Array[Vector2i] = [Vector2i(6,6), Vector2i(6,7), Vector2i(7,6), Vector2i(7,7)]
	while not powering_queue.is_empty():
		var p = powering_queue.pop_back()
		var t: Tile = flattened[p.x][p.y]
		if t.connected_up:
			if p.y != 0:
				var o: Tile = flattened[p.x][p.y - 1]
				if not o.is_powered:
					if o.connected_down:
						o.is_powered = true
						powering_queue.push_back(Vector2i(p.x, p.y - 1))
		if t.connected_down:
			if p.y != 13:
				var o: Tile = flattened[p.x][p.y + 1]
				if not o.is_powered:
					if o.connected_up:
						o.is_powered = true
						powering_queue.push_back(Vector2i(p.x, p.y + 1))
		if t.connected_left:
			if p.x != 0:
				var o: Tile = flattened[p.x - 1][p.y]
				if not o.is_powered:
					if o.connected_right:
						o.is_powered = true
						powering_queue.push_back(Vector2i(p.x - 1, p.y))
		if t.connected_right:
			if p.x != 13:
				var o: Tile = flattened[p.x + 1][p.y]
				if not o.is_powered:
					if o.connected_left:
						o.is_powered = true
						powering_queue.push_back(Vector2i(p.x + 1, p.y))



func _ready() -> void:
	instance = self
	await get_tree().create_timer(0).timeout
	recalc_paths()


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("debug"):
		recalc_paths()
