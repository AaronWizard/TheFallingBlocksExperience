extends Control

signal start

func _on_start_pressed():
	emit_signal("start")

func _on_quit_pressed():
	get_tree().quit()

func _on_instructions_pressed():
	pass