tool
extends TileMap

export(Vector2) var board_size = Vector2(10, 20) setget _set_size

const BORDER_TILE_NAME = "grey"

var _block_tiles # [{pos:a, type:b}, ...]

var _game_over

func _ready():
	$current_tile.tile_set = tile_set
	$current_tile.cell_size = cell_size

	_game_over = false

	if not Engine.editor_hint:
		randomize()
		_block_tiles = []
		_spawn_block()

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

static func _make_block_tile(pos, type):
	return {"pos": pos, "type": type}

func _on_timer_timeout():
	if not _game_over:
		if _block_tiles.size() > 0:
			_move_block()
		else:
			_spawn_block()

func _spawn_block():
	var index = randi() % $blocks.get_child_count()
	var block = $blocks.get_child(index)

	var board_middle = int(board_size.x / 2)
	var block_middle = int(block.get_used_rect().size.x / 2)

	var pos = Vector2(board_middle - block_middle + 1, 1)

	for cell in block.get_used_cells():
		var value = _make_block_tile(cell + pos, block.get_cellv(cell))
		_block_tiles.append(value)

	_draw_block()
	if not _is_block_space_empty():
		_end_game()

func _get_translated_tiles(pos):
	var result = []
	for tile in _block_tiles:
		var tile_pos = tile.pos + pos
		var value = _make_block_tile(tile_pos, tile.type)
		result.append(value)
	return result

func _clear_block():
	for tile in _block_tiles:
		$current_tile.set_cellv(tile.pos, -1)

func _draw_block():
	for tile in _block_tiles:
		$current_tile.set_cellv(tile.pos, tile.type)

func _end_block():
	for tile in _block_tiles:
		set_cellv(tile.pos, tile.type)
	$current_tile.clear()
	_block_tiles.clear()

func _move_block():
	_clear_block()

	for tile in _block_tiles:
		tile.pos.y += 1

	_draw_block()

	if not _is_block_space_empty(Vector2(0, 1)):
		_end_block()

func _is_block_space_empty(pos = Vector2()):
	var result = true

	for tile in _get_translated_tiles(pos):
		if get_cellv(tile.pos) != -1:
			result = false
			break

	return result

func _end_game():
	_game_over = true
	$timer.stop()
	print("game over")