tool
extends Node2D

export(Vector2) var board_size = Vector2(10, 20) setget _set_size

const BORDER_TILE_NAME = "grey"
const INPUT_TIME = 1.0 / 60.0

var _block_types = [
	preload("res://blocks/i.tscn")#,
	#preload("res://blocks/j.tscn"),
	#preload("res://blocks/l.tscn"),
	#preload("res://blocks/o.tscn"),
	#reload("res://blocks/s.tscn"),
	#preload("res://blocks/t.tscn"),
	#preload("res://blocks/z.tscn")
]

var _block
var _game_over

func _ready():
	_block = null
	_game_over = false

	if not Engine.editor_hint:
		randomize()
		_spawn_block()

func _set_size(value):
	board_size = value

	if get_child_count() > 0:
		$board_tiles.clear()

		var border_tile = $board_tiles.tile_set.find_tile_by_name(
				BORDER_TILE_NAME)
		assert(border_tile != null)

		# Top and bottom
		for x in range(board_size.x + 2):
			$board_tiles.set_cell(x, 0, border_tile)
			$board_tiles.set_cell(x, board_size.y + 1, border_tile)

		# Left and right
		for y in range(1, board_size.y + 1):
			$board_tiles.set_cell(0, y, border_tile)
			$board_tiles.set_cell(board_size.x + 1, y, border_tile)

func _on_timer_timeout():
	if not _game_over:
		if _block != null:
			_drop_block()
		else:
			_spawn_block()

func _on_input_timer_timeout():
	if _block != null:
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

		_move_block(move, rotate)

func _spawn_block():
	var index = randi() % _block_types.size()
	_block = _block_types[index].instance()
	add_child(_block)

	var block_rect = _block.get_rect()

	var board_middle = int(board_size.x / 2)
	var block_middle = int(block_rect.size.x / 2)

	var block_pos = Vector2(board_middle - block_middle + 1, 1)
	_block.block_position = block_pos

	if not _is_block_space_empty(block_pos, 0):
		_end_game()

func _drop_block():
	if not Input.is_action_pressed("move_down"):
		_move_block(Vector2(0, 1), 0)

	if not _is_block_space_empty(_block.block_position + Vector2(0, 1),
			_block.block_rotation):
		_end_block()

func _move_block(pos, rot):
	var new_pos = _block.block_position + pos
	var new_rot = _block.block_rotation + rot

	if _is_block_space_empty(new_pos, new_rot):
		_block.block_position = new_pos
		_block.block_rotation = new_rot

func _is_block_space_empty(pos, rot):
	var result = true
	for t in _block.get_tiles(pos, rot):
		if $board_tiles.get_cellv(t) != -1:
			result = false
			break
	return result

func _end_block():
	var tiles = _block.get_tiles()
	for t in tiles:
		$board_tiles.set_cellv(t + _block.block_position,
				_block.get_tile_type(t))

	_block.queue_free()
	_block = null

	_check_for_completed_lines()

func _check_for_completed_lines():
	var rows = []
	for y in range(board_size.y, 0, -1):
		var complete = true
		for x in range(1, board_size.x + 1):
			if $board_tiles.get_cell(x, y) == -1:
				complete = false
				break
		if complete:
			rows.append(y)

	while not rows.empty():
		var current_y = rows.front()

		rows.pop_front()
		for i in range(rows.size()):
			rows[i] -= 1

		for x in range(1, board_size.x + 1):
			for y in range(current_y, 0, -1):
				if y - 1 > 0:
					var tile_above = $board_tiles.get_cell(x, y - 1)
					$board_tiles.set_cell(x, y, tile_above)
				else:
					$board_tiles.set_cell(x, y, -1)

func _end_game():
	_game_over = true
	$timer.stop()
	print("game over")