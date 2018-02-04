extends Node

func _on_title_start():
	$title.visible = false
	$board.start_game()

func _on_board_game_over():
	$title.visible = true