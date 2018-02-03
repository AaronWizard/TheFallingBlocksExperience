tool
extends TileMap

export(Vector2) var board_size = Vector2(10, 20) setget _set_size

const BORDER_TILE_NAME = "grey"
const INPUT_TIME = 1.0 / 60.0

var _center_points

var _block_index
var _block_pos
var _block_rotation

var _game_over

func _ready():
	$current_tile.tile_set = tile_set
	$current_tile.cell_size = cell_size

	_game_over = false

	if not Engine.editor_hint:
		randomize()
		_init_center_points()
		_spawn_block()

func _init_center_points():
	_center_points = []
	for b in $blocks.get_children():
		var size = b.get_used_rect().size
		var center = Vector2(int(size.x / 2), int(size.y / 2))
		_center_points.append(center)

func _set_size(value):
	board_size = value

	clear()

	var border_tile = tile_set.find_tile_by_name(BORDER_TILE_NAME)
	assert(border_tile != null)

	# Top and bottom
	for x in range(board_size.x + 2):
		set_cell(x, 0, border_tile)
		set_cell(x, board_size.y + 1, border_tile)

	# Left and right
	for y in range(1, board_size.y + 1):
		set_cell(0, y, border_tile)
		set_cell(board_size.x + 1, y, border_tile)

func _on_timer_timeout():
	if not _game_over:
		if _block_index > -1:
			_drop_block()
		else:
			_spawn_block()

func _spawn_block():
	_block_index = randi() % $blocks.get_child_count()

	var block = $blocks.get_child(_block_index)
	var board_middle = int(board_size.x / 2)
	var block_middle = int(block.get_used_rect().size.x / 2)

	_block_pos = Vector2(board_middle - block_middle + 1, 1)
	_block_rotation = 0

	_draw_current_block()
	if not _is_block_space_empty(_block_pos, _block_rotation):
		_end_game()

func _get_block_tiles(pos = _block_pos, rot = _block_rotation):
	var result = {}

	var block = $blocks.get_child(_block_index)
	var center = _center_points[_block_index]

	for tile in block.get_used_cells():
		var real_tile = (tile - center).rotated(rot) + center + pos
		result[tile] = real_tile
	return result

func _clear_block():
	var tiles = _get_block_tiles()
	for t in tiles.values():
		$current_tile.set_cellv(t, -1)

func _draw_block(tilemap):
	var block = $blocks.get_child(_block_index)
	var tiles = _get_block_tiles()

	for t in tiles:
		var real_tile = tiles[t]
		tilemap.set_cellv(real_tile, block.get_cellv(t))

func _draw_current_block():
	_draw_block($current_tile)

func _end_block():
	_draw_block(self)
	$current_tile.clear()
	_block_index = -1

func _drop_block():
	if not Input.is_action_pressed("move_down"):
		_move_block(Vector2(0, 1), 0)

func _move_block(pos, rot):
	if _is_block_space_empty(_block_pos + pos, _block_rotation + rot):
		_clear_block()
		_block_pos += pos
		_block_rotation += rot
		_draw_current_block()

		if not _is_block_space_empty(_block_pos + Vector2(0, 1), 0):
			_end_block()

func _on_input_timer_timeout():
	if _block_index > -1:
		var move = Vector2()
		var rotate = 0
	
		if Input.is_action_pressed("move_left"):
			move.x -= 1
		if Input.is_action_pressed("move_right"):
			move.x += 1
		if Input.is_action_pressed("move_down"):
			move.y += 1
	
		if Input.is_action_pressed("rotate_ccw"):
			rotate -= 1
		if Input.is_action_pressed("rotate_cw"):
			rotate += 1
	
		_move_block(move, 0)

func _is_block_space_empty(pos, rot):
	var result = true

	var tiles = _get_block_tiles(pos, rot)
	for t in tiles.values():
		if get_cellv(t) != -1:
			result = false
			break

	return result

func _end_game():
	_game_over = true
	$timer.stop()
	print("game over")