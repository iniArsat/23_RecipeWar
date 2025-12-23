extends Node2D
class_name RangeVisual

var radius: float = 0.0
var color: Color = Color(0.2, 0.8, 1.0, 0.2)  # Biru transparan
var border_color: Color = Color(0.2, 0.8, 1.0, 0.5)
var border_width: float = 2.0

func _draw():
	# Draw filled circle
	draw_circle(Vector2.ZERO, radius, color)
	# Draw border
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, border_color, border_width)

func update_radius(new_radius: float):
	radius = new_radius
	queue_redraw()

func set_visibility(is_visible: bool):
	visible = is_visible
