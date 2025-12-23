extends Node

signal screen_clicked(position: Vector2)

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		emit_signal("screen_clicked", event.position)
