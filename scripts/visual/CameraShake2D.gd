extends Camera2D

# --- Shake state ---
var _shake_strength: float = 0.0
var _shake_duration: float = 0.0

# --- Follow state ---
var _target_position: Vector2 = Vector2(640, 360)
var _base_zoom: float = 1.0
var _target_zoom: float = 1.0
var _clash_cooldown: float = 0.0

@export var follow_speed: float = 4.0
@export var zoom_speed: float = 2.0

func shake(strength: float, duration: float = 0.3) -> void:
	if strength > _shake_strength:
		_shake_strength = strength
	if duration > _shake_duration:
		_shake_duration = duration

func _ready() -> void:
	global_position = Vector2(640, 360)

func _process(delta: float) -> void:
	_update_follow(delta)
	_update_shake(delta)
	_update_zoom(delta)

# ---------------------------------------------------------------------------
# Follow — smooth-lerp toward midpoint of frontmost units
# ---------------------------------------------------------------------------
func _update_follow(_delta: float) -> void:
	var main = get_parent()
	if not main:
		return
	var player_container = main.get_node("World/PlayerUnits")
	var enemy_container = main.get_node("World/EnemyUnits")
	if not player_container or not enemy_container:
		return

	var player_front = _get_frontmost_x(player_container, true)
	var enemy_front = _get_frontmost_x(enemy_container, false)

	if player_front == INF and enemy_front == INF:
		_target_position = Vector2(640, 360)
		_target_zoom = _base_zoom
	else:
		var mid_x: float
		if player_front == INF:
			mid_x = enemy_front
		elif enemy_front == INF:
			mid_x = player_front
		else:
			mid_x = (player_front + enemy_front) * 0.5

		_target_position.x = mid_x
		_target_position.y = 360.0

		_check_clash(player_container, enemy_container)

	# Clamp to playable bounds
	_target_position.x = clamp(_target_position.x, 300.0, 980.0)

	global_position = global_position.lerp(_target_position, follow_speed * _delta)

static func _get_frontmost_x(container: Node, is_player: bool) -> float:
	var best = INF if is_player else -INF
	var found = false
	for child in container.get_children():
		if not is_instance_valid(child):
			continue
		if child.has_method("is_dead") and child.is_dead():
			continue
		if not child.has_method("get_team"):
			continue
		found = true
		if is_player:
			if child.global_position.x < best:
				best = child.global_position.x
		else:
			if child.global_position.x > best:
				best = child.global_position.x
	return best if found else INF

# ---------------------------------------------------------------------------
# Clash detection — zoom out when many units are near each other
# ---------------------------------------------------------------------------
func _check_clash(player_container: Node, enemy_container: Node) -> void:
	var battle_field := Rect2(0, 0, 1280, 720)
	var unit_count := 0

	for container in [player_container, enemy_container]:
		for child in container.get_children():
			if not is_instance_valid(child):
				continue
			if child.has_method("is_dead") and child.is_dead():
				continue
			if battle_field.has_point(child.global_position):
				unit_count += 1

	var clash_intensity = clamp((unit_count - 10) / 20.0, 0.0, 1.0)
	if clash_intensity > 0.0:
		_target_zoom = _base_zoom - clamp(clash_intensity * 0.15, 0.0, 0.15)
		_clash_cooldown = 2.0
	elif _clash_cooldown > 0.0:
		_clash_cooldown -= get_process_delta_time()
		if _clash_cooldown <= 0.0:
			_target_zoom = _base_zoom

# ---------------------------------------------------------------------------
# Shake — random offset decaying to zero
# ---------------------------------------------------------------------------
func _update_shake(delta: float) -> void:
	if _shake_duration <= 0.0:
		offset = Vector2.ZERO
		return

	_shake_duration -= delta
	if _shake_duration <= 0.0:
		_shake_strength = 0.0
		offset = Vector2.ZERO
		return

	offset = Vector2(
		randf_range(-_shake_strength, _shake_strength),
		randf_range(-_shake_strength, _shake_strength),
	)
	_shake_strength = move_toward(_shake_strength, 0.0, _shake_strength * 3.0 * delta)

# ---------------------------------------------------------------------------
# Zoom — smooth transition
# ---------------------------------------------------------------------------
func _update_zoom(delta: float) -> void:
	var current = zoom.x
	var new_zoom = move_toward(current, _target_zoom, zoom_speed * delta)
	zoom = Vector2(new_zoom, new_zoom)
