extends Node2D

export(int, 3) var block_rotation = 0 setget _set_block_rotation

var _current_orientation

func _ready():
	_set_block_rotation(block_rotation)

func _set_block_rotation(value):
	block_rotation = value
	if get_child_count() > 0:
		var real_rotation = wrapi(block_rotation, 0, get_child_count())

		for c in get_children():
			c.visible = c.get_index() == real_rotation
			if c.visible:
				_current_orientation = c

func get_tiles():
	return _current_orientation.get_used_cells()

func get_tile_type(tile):
	return _current_orientation.get_cellv(tile)