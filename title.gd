extends Control

signal start

func _input(event):
	if visible:
		if event.is_action_pressed("cancel"):
			get_tree().quit()
		elif event is InputEventKey and event.pressed:
			get_tree().set_input_as_handled()
			emit_signal("start")