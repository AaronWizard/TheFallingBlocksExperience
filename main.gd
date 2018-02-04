extends Node

func _ready():
	$pause.visible = false

func _notification(what):
	if (what == MainLoop.NOTIFICATION_WM_FOCUS_OUT) and not $title.visible:
		_on_board_pause()

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