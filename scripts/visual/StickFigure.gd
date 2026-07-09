extends Node2D

var arm_l: Polygon2D
var arm_r: Polygon2D
var leg_l: Polygon2D
var leg_r: Polygon2D

var arm_l_base: float
var arm_r_base: float
var leg_l_base: float
var leg_r_base: float

var _walk_time: float = 0.0
var _base_modulate: Color = Color.WHITE
var _rage_glow_enabled: bool = false
var _rage_pulse_time: float = 0.0

func _ready():
	arm_l = $ArmL
	arm_r = $ArmR
	leg_l = $LegL
	leg_r = $LegR
	arm_l_base = arm_l.rotation
	arm_r_base = arm_r.rotation
	leg_l_base = leg_l.rotation
	leg_r_base = leg_r.rotation
	_base_modulate = modulate

func set_body_color(color: Color):
	for child in get_children():
		if child is Polygon2D and child.name != "Weapon":
			child.color = color

func flash(flash_color: Color, normal_color: Color):
	for child in get_children():
		if child is Polygon2D and child.name != "Weapon":
			var t = create_tween()
			t.tween_property(child, "color", flash_color, 0.05)
			t.tween_property(child, "color", normal_color, 0.1)

func set_walking(walking: bool, delta: float):
	if walking:
		_walk_time += delta * 8.0
		var swing = sin(_walk_time) * 0.6
		arm_l.rotation = arm_l_base + swing
		arm_r.rotation = arm_r_base - swing
		leg_l.rotation = leg_l_base - swing
		leg_r.rotation = leg_r_base + swing
	else:
		var dt = delta * 12.0
		arm_l.rotation = move_toward(arm_l.rotation, arm_l_base, dt)
		arm_r.rotation = move_toward(arm_r.rotation, arm_r_base, dt)
		leg_l.rotation = move_toward(leg_l.rotation, leg_l_base, dt)
		leg_r.rotation = move_toward(leg_r.rotation, leg_r_base, dt)
		_walk_time = 0.0

func play_attack(_look_dir: float) -> void:
	var target_rot = arm_r_base - 1.0
	var t = create_tween()
	t.tween_property(arm_r, "rotation", target_rot, 0.04)
	t.tween_property(arm_r, "rotation", arm_r_base, 0.08).set_delay(0.04)

func set_rage_glow(enabled: bool) -> void:
	if enabled == _rage_glow_enabled:
		return
	_rage_glow_enabled = enabled
	_rage_pulse_time = 0.0
	if enabled:
		modulate = Color(1.15, 0.95, 0.7)
	else:
		modulate = _base_modulate

func _process(delta: float) -> void:
	if _rage_glow_enabled:
		_rage_pulse_time += delta * 6.0
		var pulse = 1.0 + sin(_rage_pulse_time) * 0.08
		modulate = Color(1.15 * pulse, 0.95 * pulse, 0.7 * pulse)
