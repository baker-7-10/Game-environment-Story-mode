extends CharacterBody2D

@export var stats: Resource
@export var team: int = 0
@export var unit_type: String = ""

var current_health: float
var target: Node2D = null
var look_direction: float = 1.0
var gold_carried: int = 0

var state_machine: Node
var attack_timer: Timer
var health_bar: Node2D
var attack_range_area: Area2D

var _dead_script: GDScript
var _camera: Node
var _sound_mgr: Node
var _spark_scene = preload("res://scenes/HitSpark.tscn")

var selected: bool = false
var move_to_position: Vector2 = Vector2(-1, -1)
var direct_control: bool = false
var mine_index: int = -1
var hold_wave: bool = false

@onready var visual: Node2D = $Visual
@onready var selection_ring: Polygon2D = $SelectionRing

func _stat(key: String, default_val = 0.0):
	var base = stats[key] if stats and key in stats else default_val
	if team == Global.PLAYER_TEAM and unit_type:
		base *= SaveManager.get_upgrade_mult_for(unit_type, key)
	if Global.is_rage_active(team):
		match key:
			"damage":
				base *= Global.RAGE_DAMAGE_MULT
			"move_speed":
				base *= Global.RAGE_SPEED_MULT
			"attack_cooldown":
				base /= Global.RAGE_SPEED_MULT
	return base

func _ready() -> void:
	_dead_script = preload("res://scripts/units/states/DeadState.gd")
	current_health = _stat("max_health", 100.0)
	state_machine = $StateMachine
	attack_timer = $AttackCooldown
	attack_timer.wait_time = _stat("attack_cooldown", 1.0)
	health_bar = $HealthBar
	attack_range_area = $AttackRange

	var root = get_tree().current_scene
	_camera = root.get_node("Camera")
	_sound_mgr = root.get_node("SoundManager")

	var c = Color(0.3, 0.6, 1.0) if team == Global.PLAYER_TEAM else Color(1.0, 0.3, 0.3)
	if visual.has_method("set_body_color"):
		visual.set_body_color(c)

	if attack_range_area:
		var shape_node = attack_range_area.get_node("CollisionShape2D")
		if shape_node and shape_node.shape is CircleShape2D:
			shape_node.shape.radius = _stat("attack_range", 50.0)

func _process(delta: float) -> void:
	if health_bar and health_bar.has_method("update_hp"):
		health_bar.update_hp(current_health, _stat("max_health", 100.0))
	if visual and visual.has_method("set_walking"):
		visual.set_walking(velocity.length_squared() > 0.1, delta)
	if visual and visual.has_method("set_rage_glow"):
		visual.set_rage_glow(Global.is_rage_active(team))

func target_is_valid() -> bool:
	if not is_instance_valid(target):
		return false
	if target.has_method("is_dead") and target.is_dead():
		return false
	return true

func acquire_target() -> void:
	if not attack_range_area:
		return
	var overlapping = attack_range_area.get_overlapping_bodies()
	var nearest: Node2D = null
	var nearest_dist: float = INF
	for body in overlapping:
		if body == self:
			continue
		if body.has_method("get_team") and body.get_team() != team:
			var d = global_position.distance_squared_to(body.global_position)
			if d < nearest_dist:
				nearest_dist = d
				nearest = body
	target = nearest

func can_attack() -> bool:
	return attack_timer.is_stopped()

func do_attack() -> void:
	apply_damage_to_target(_stat("damage", 10.0))

func perform_attack() -> void:
	attack_timer.start()
	do_attack()
	if visual and visual.has_method("play_attack"):
		visual.play_attack(look_direction)

func apply_damage_to_target(amount: float) -> void:
	if not target or not is_instance_valid(target):
		return
	if target.has_method("take_damage"):
		target.take_damage(amount, self)
	var is_kill = target.has_method("is_dead") and target.is_dead() if is_instance_valid(target) else false
	Global.apply_hit_stop(0.1 if is_kill else 0.05)
	_spawn_spark(target.global_position if is_instance_valid(target) else global_position + Vector2(look_direction * 20, -5), Color(1, 0.85, 0.3))
	if _sound_mgr and _sound_mgr.has_method("play_hit"):
		_sound_mgr.play_hit(global_position)
	_hit_feedback()

func _spawn_spark(at: Vector2, spark_color: Color = Color(1, 0.9, 0.5)) -> void:
	var spark = _spark_scene.instantiate()
	spark.global_position = at
	spark.color = spark_color
	spark.finished.connect(spark.queue_free)
	get_tree().current_scene.add_child(spark)

func take_damage(amount: float, _source: Node2D = null) -> void:
	current_health = max(0.0, current_health - amount)
	_spawn_spark(global_position, Color(1, 0.9, 0.7))
	_hit_feedback()
	_show_damage_number(amount)
	if current_health <= 0:
		die()

func die() -> void:
	if _camera and _camera.has_method("shake"):
		_camera.shake(4.0, 0.25)
	if state_machine and state_machine.has_method("change_to"):
		state_machine.change_to("dead")

func is_dead() -> bool:
	if not state_machine or not state_machine.current_state:
		return false
	return state_machine.current_state.get_script() == _dead_script

func _hit_feedback() -> void:
	if not visual or not visual.has_method("flash"):
		return
	var c = Color(0.3, 0.6, 1.0) if team == Global.PLAYER_TEAM else Color(1.0, 0.3, 0.3)
	visual.flash(Color.WHITE, c)

func get_team() -> int:
	return team

func get_unit_type() -> String:
	return unit_type

func get_mine_positions() -> Array:
	if team == Global.PLAYER_TEAM:
		return [Vector2(300, 260), Vector2(300, 360), Vector2(300, 460)]
	else:
		return [Vector2(980, 260), Vector2(980, 360), Vector2(980, 460)]

func get_mine_position() -> Vector2:
	var positions = get_mine_positions()
	if mine_index >= 0 and mine_index < positions.size():
		return positions[mine_index]
	return positions[1]

func get_base_position() -> Vector2:
	if team == Global.PLAYER_TEAM:
		return Vector2(100, 360)
	else:
		return Vector2(1180, 360)

func set_selected(val: bool) -> void:
	selected = val
	if selection_ring:
		selection_ring.visible = val

func set_hold_wave(val: bool) -> void:
	hold_wave = val

func is_hold_wave() -> bool:
	return hold_wave

func cmd_move_to(pos: Vector2) -> void:
	move_to_position = pos
	if unit_type == "miner":
		state_machine.change_to("miner_move", {"destination": pos})
	else:
		state_machine.change_to("move")

func _show_damage_number(amount: float) -> void:
	var label = Label.new()
	label.text = str(int(amount))
	label.add_theme_color_override("font_color", Color(1, 0.3, 0.3))
	label.add_theme_font_size_override("font_size", 14)
	label.position = Vector2(-10, -45)
	add_child(label)
	var tween = create_tween()
	tween.tween_property(label, "position:y", -65, 0.6)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.6)
	tween.finished.connect(label.queue_free)
