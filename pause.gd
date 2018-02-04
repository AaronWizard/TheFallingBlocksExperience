extends Control

signal end_game

func _input(event):
	if visible:
		if event.is_action_pressed("cancel"):
			get_tree().set_input_as_handled()
			get_tree().paused = false
			visible = false
			emit_signal("end_game")
		elif event is InputEventKey and event.pressed:
			get_tree().set_input_as_handled()
			get_tree().paused = false
			visible = false