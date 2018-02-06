extends Node

const CONFIG_FILE = "user://config.cfg"

const CONFIG_WINDOW = "window"
const CONFIG_WINDOW_SIZE = "size"

func _ready():
	$pause.visible = false
	_load_screen_config()
	get_tree().connect("screen_resized", self, "_screen_resized")

func _notification(what):
	if (what == MainLoop.NOTIFICATION_WM_FOCUS_OUT) and not $title.visible:
		_on_board_pause()

func _load_screen_config():
	var config = ConfigFile.new()
	var err = config.load(CONFIG_FILE)
	if (err != OK) \
			or not config.has_section_key(CONFIG_WINDOW, CONFIG_WINDOW_SIZE):
		config.set_value(CONFIG_WINDOW, CONFIG_WINDOW_SIZE, OS.window_size)
		config.save(CONFIG_FILE)
	else:
		var window_size = config.get_value(CONFIG_WINDOW, CONFIG_WINDOW_SIZE)
		OS.window_size = window_size

func _screen_resized():
	var config = ConfigFile.new()
	var err = config.load(CONFIG_FILE)
	assert(err == OK)
	config.set_value(CONFIG_WINDOW, CONFIG_WINDOW_SIZE, OS.window_size)
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