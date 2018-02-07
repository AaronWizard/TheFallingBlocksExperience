extends Control

signal done

func _on_done_pressed():
	emit_signal("done")