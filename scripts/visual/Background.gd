extends Node2D

var _camera: Node2D
var _camera_offset := Vector2.ZERO

const EXTEND_LEFT := 500
const EXTEND_RIGHT := 600
const DRAW_W := 1280 + EXTEND_LEFT + EXTEND_RIGHT

func _ready() -> void:
	_camera = get_parent().get_node("Camera")

func _process(_delta: float) -> void:
	if not _camera:
		return
	_camera_offset = _camera.global_position - Vector2(640, 360)
	queue_redraw()

func _draw() -> void:
	_draw_sky()
	_draw_clouds()
	_draw_far_hills()
	_draw_near_hills()
	_draw_ground()

# ---------------------------------------------------------------------------
# Sky — parallax factor 0.0 (fixed to world, scrolls at full camera speed)
# ---------------------------------------------------------------------------
func _draw_sky() -> void:
	var ox = _camera_offset.x * 0.0
	var sky_top = Color(0.06, 0.06, 0.18)
	var sky_mid = Color(0.12, 0.18, 0.4)
	var sky_bot = Color(0.2, 0.35, 0.55)
	var x0 = -EXTEND_LEFT + ox
	var xw = DRAW_W

	for y in range(0, 360, 2):
		var t = y / 360.0
		var c: Color
		if t < 0.5:
			c = sky_top.lerp(sky_mid, t * 2.0)
		else:
			c = sky_mid.lerp(sky_bot, (t - 0.5) * 2.0)
		draw_rect(Rect2(x0, y, xw, 2), c)

# ---------------------------------------------------------------------------
# Clouds — parallax factor 0.05
# ---------------------------------------------------------------------------
func _draw_clouds() -> void:
	var ox = _camera_offset.x * 0.05
	var cloud_c = Color(1, 1, 1, 0.12)

	var cloud_positions = [
		Vector2(120, 55), Vector2(150, 50), Vector2(165, 60),
		Vector2(750, 85), Vector2(775, 80),
		Vector2(1050, 45), Vector2(1080, 40),
		Vector2(-200, 70), Vector2(-175, 65),
		Vector2(1400, 55), Vector2(1425, 50),
	]
	for cp in cloud_positions:
		var p = cp + Vector2(ox, 0)
		draw_circle(p, 35, cloud_c)
		draw_circle(p + Vector2(28, -5), 28, cloud_c)
		draw_circle(p + Vector2(-22, 5), 22, cloud_c)

# ---------------------------------------------------------------------------
# Far hills (back layer) — parallax factor 0.15
# ---------------------------------------------------------------------------
func _draw_far_hills() -> void:
	var ox = _camera_offset.x * 0.15
	var hill_c = Color(0.07, 0.18, 0.07)

	for i in range(-1, 2):
		var cx = i * 600 + ox
		var poly = PackedVector2Array([
			Vector2(cx - 300, 360),
			Vector2(cx - 250, 320),
			Vector2(cx - 200, 290),
			Vector2(cx - 150, 310),
			Vector2(cx - 100, 288),
			Vector2(cx - 50, 300),
			Vector2(cx, 295),
			Vector2(cx + 50, 320),
			Vector2(cx + 100, 305),
			Vector2(cx + 150, 330),
			Vector2(cx + 200, 340),
			Vector2(cx + 300, 360),
		])
		draw_colored_polygon(poly, hill_c)

# ---------------------------------------------------------------------------
# Near hills (front layer) — parallax factor 0.3
# ---------------------------------------------------------------------------
func _draw_near_hills() -> void:
	var ox = _camera_offset.x * 0.3
	var hill_c = Color(0.09, 0.22, 0.09)

	for i in range(-1, 2):
		var cx = i * 600 + ox
		var poly = PackedVector2Array([
			Vector2(cx - 300, 360),
			Vector2(cx - 220, 340),
			Vector2(cx - 150, 332),
			Vector2(cx - 80, 338),
			Vector2(cx, 335),
			Vector2(cx + 70, 345),
			Vector2(cx + 150, 340),
			Vector2(cx + 220, 350),
			Vector2(cx + 300, 360),
		])
		draw_colored_polygon(poly, hill_c)

# ---------------------------------------------------------------------------
# Ground — parallax factor 1.0 (screen-fixed = follows camera 1:1)
# ---------------------------------------------------------------------------
func _draw_ground() -> void:
	var ox = _camera_offset.x * 1.0

	var x0 = -EXTEND_LEFT + ox
	var xw = DRAW_W

	var top_c = Color(0.25, 0.18, 0.09)
	var mid_c = Color(0.18, 0.12, 0.05)
	var bot_c = Color(0.10, 0.07, 0.03)

	for y in range(360, 400, 2):
		var t = (y - 360) / 40.0
		var c: Color
		if t < 0.5:
			c = top_c.lerp(mid_c, t * 2.0)
		else:
			c = mid_c.lerp(bot_c, (t - 0.5) * 2.0)
		draw_rect(Rect2(x0, y, xw, 2), c)

	# Grass line at the top surface
	draw_rect(Rect2(x0, 360, xw, 3), Color(0.14, 0.42, 0.14))
