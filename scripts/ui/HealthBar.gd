extends Node2D
class_name HealthBar

# Draw-based world-space health bar. No external textures needed.
# Updates via queue_redraw() when value changes.

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
	draw_rect(Rect2(-half_w, 0, bar_width, bar_height), Color(0.15, 0.15, 0.15, 0.9))
	var fill_color = Color.GREEN
	if value < 0.3:
		fill_color = Color.RED
	elif value < 0.6:
		fill_color = Color.YELLOW
	draw_rect(Rect2(-half_w, 0, bar_width * value, bar_height), fill_color)
