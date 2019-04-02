extends Node

const CONFIG_FILE = "user://config.cfg"

const CONFIG_WINDOW = "window"
const CONFIG_WINDOW_SIZE = "size"
const CONFIG_WINDOW_POS = "position"

func _ready():
	$pause.visible = false

	_load_screen_config()
	#warning-ignore:return_value_discarded
	get_tree().connect("screen_resized", self, "_save_screen_size")

func _notification(what):
	match what:
		MainLoop.NOTIFICATION_WM_FOCUS_OUT:
			if not $title.visible:
				_on_board_pause()
		MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
			_save_screen_pos()

func _load_screen_config():
	var config = ConfigFile.new()
	var err = config.load(CONFIG_FILE)
	if (err != OK) \
			or not config.has_section_key(CONFIG_WINDOW, CONFIG_WINDOW_SIZE) \
			or not config.has_section_key(CONFIG_WINDOW, CONFIG_WINDOW_POS):
		config.set_value(CONFIG_WINDOW, CONFIG_WINDOW_POS, OS.window_size)
		config.set_value(CONFIG_WINDOW, CONFIG_WINDOW_POS, OS.window_position)
		config.save(CONFIG_FILE)
	else:
		var window_size = config.get_value(CONFIG_WINDOW, CONFIG_WINDOW_SIZE)
		OS.window_size = window_size
		var window_pos = config.get_value(CONFIG_WINDOW, CONFIG_WINDOW_POS)
		OS.window_position = window_pos

func _save_screen_size():
	var config = ConfigFile.new()
	var err = config.load(CONFIG_FILE)
	assert(err == OK)
	config.set_value(CONFIG_WINDOW, CONFIG_WINDOW_SIZE, OS.window_size)
	config.save(CONFIG_FILE)

func _save_screen_pos():
	var config = ConfigFile.new()
	var err = config.load(CONFIG_FILE)
	assert(err == OK)
	config.set_value(CONFIG_WINDOW, CONFIG_WINDOW_POS, OS.window_position)
	config.save(CONFIG_FILE)

func _on_title_start():
	$title.visible = false
	$board.start_game()

func _on_board_game_over():
	$title.visible = true

func _on_board_pause():
	get_tree().paused = true
	$pause.visible = true

func _on_pause_end_game():
	$board.end_game()
	$title.visible = true