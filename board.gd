tool
extends TileMap

export(Vector2) var board_size = Vector2(10, 20) setget _set_size

const BORDER_TILE_NAME = "grey"

func _ready():
	pass
	#self.board_size = Vector2(5, 3)

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