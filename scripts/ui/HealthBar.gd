extends Node2D

var value: float = 1.0
var bar_width: float = 40.0
var bar_height: float = 5.0

func _ready() -> void:
	position.y = -30.0

func update_value(v: float) -> void:
	value = clampf(v, 0.0, 1.0)
	queue_redraw()

func _draw() -> void:
	var half_w = bar_width / 2.0
	var bg_rect = Rect2(-half_w, 0, bar_width, bar_height)
	draw_rect(bg_rect, Color(0.1, 0.1, 0.1, 0.95))
	draw_rect(Rect2(-half_w - 1, -1, bar_width + 2, bar_height + 2), Color(0.4, 0.4, 0.4, 0.8), false, 1.0)

	var fill_color = Color.GREEN
	if value < 0.3:
		fill_color = Color.RED
	elif value < 0.6:
		fill_color = Color.YELLOW
	draw_rect(Rect2(-half_w + 1, 1, (bar_width - 2) * value, bar_height - 2), fill_color)
