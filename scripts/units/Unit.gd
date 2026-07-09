class_name Unit
extends CharacterBody2D

@export var stats: UnitStats
@export var team: int = 0

var current_health: float
var target: Node2D = null
var look_direction: float = 1.0
var gold_carried: int = 0

var state_machine: StateMachine
var attack_timer: Timer
var health_bar: HealthBar
var attack_range_area: Area2D

@onready var visual: Polygon2D = $Visual

func _ready() -> void:
	current_health = stats.max_health
	state_machine = $StateMachine
	attack_timer = $AttackCooldown
	attack_timer.wait_time = stats.attack_cooldown
	health_bar = $HealthBar
	attack_range_area = $AttackRange

	if team == Global.PLAYER_TEAM:
		visual.color = Color(0.3, 0.6, 1.0)
	else:
		visual.color = Color(1.0, 0.3, 0.3)

	if attack_range_area:
		var shape_node = attack_range_area.get_node("CollisionShape2D")
		if shape_node and shape_node.shape is CircleShape2D:
			shape_node.shape.radius = stats.attack_range

func _process(_delta: float) -> void:
	if health_bar:
		health_bar.update_value(current_health / stats.max_health)

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
		if body is Unit and body.team != team:
			var d = global_position.distance_squared_to(body.global_position)
			if d < nearest_dist:
				nearest_dist = d
				nearest = body
		if body.has_method("get_team") and body.get_team() != team:
			var d = global_position.distance_squared_to(body.global_position)
			if d < nearest_dist:
				nearest_dist = d
				nearest = body
	target = nearest

func can_attack() -> bool:
	return attack_timer.is_stopped()

func perform_attack() -> void:
	attack_timer.start()
	if has_method("do_attack"):
		do_attack()
	else:
		apply_damage_to_target(stats.damage)

func apply_damage_to_target(amount: float) -> void:
	if not target or not is_instance_valid(target):
		return
	if target.has_method("take_damage"):
		target.take_damage(amount, self)
	_hit_feedback()

func take_damage(amount: float, _source: Node2D = null) -> void:
	current_health = max(0.0, current_health - amount)
	_hit_feedback()
	if current_health <= 0:
		die()

func die() -> void:
	state_machine.change_to("dead")

func is_dead() -> bool:
	return state_machine.current_state is DeadState

func _hit_feedback() -> void:
	if not visual:
		return
	var tween = create_tween()
	tween.tween_property(visual, "color", Color.WHITE, 0.05)
	tween.tween_property(visual, "color", (
		Color(0.3, 0.6, 1.0) if team == Global.PLAYER_TEAM else Color(1.0, 0.3, 0.3)
	), 0.1)

func get_team() -> int:
	return team

func get_mine_position() -> Vector2:
	return Vector2(640, 360)

func get_base_position() -> Vector2:
	if team == Global.PLAYER_TEAM:
		return Vector2(100, 360)
	else:
		return Vector2(1180, 360)
