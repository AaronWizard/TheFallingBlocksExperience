extends Control

signal start
signal options

func _on_start_pressed():
	emit_signal("start")

func _on_options_pressed():
	emit_signal("options")

func _on_quit_pressed():
	get_tree().quit()