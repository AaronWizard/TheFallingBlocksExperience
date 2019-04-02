extends Control

signal start

const INSTRUCTIONS = \
"""Left: %s
Right: %s
Down: %s
Drop: %s
Rotate Counter
Clockwise: %s
Rotate
Clockwise: %s
Pause: %s"""

var _inputs = ["move_left", "move_right", "move_down", "drop", "rotate_ccw",
		"rotate_cw", "cancel"]

func _on_start_pressed():
	emit_signal("start")

func _on_quit_pressed():
	get_tree().quit()

func _on_instructions_pressed():
	var keys = _get_input_keys()

	$instructions_popup/instructions_panel/Label.text = INSTRUCTIONS % keys
	$instructions_popup.popup()

func _get_input_keys():
	var result = []

	for input in _inputs:
		var input_str

		var action_list = InputMap.get_action_list(input)
		for a in action_list:
			if input_str:
				input_str = input_str + ", " + OS.get_scancode_string(a.scancode)
			else:
				input_str = OS.get_scancode_string(a.scancode)

		result.append(input_str)

	return result
