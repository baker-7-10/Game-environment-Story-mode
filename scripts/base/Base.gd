extends Node2D

@export var team: int = 0
@export var max_health: float = 500.0

var current_health: float

@onready var health_bar: Node2D = $HealthBar
@onready var visual: Polygon2D = $Sprite2D

func _ready() -> void:
	current_health = max_health
	if team == Global.PLAYER_TEAM:
		visual.color = Color(0.2, 0.5, 0.9)
	else:
		visual.color = Color(0.9, 0.2, 0.2)

func _process(_delta: float) -> void:
	if health_bar and health_bar.has_method("update_value"):
		health_bar.update_value(current_health / max_health)

func take_damage(amount: float, _source: Node2D = null) -> void:
	current_health = max(0.0, current_health - amount)
	SignalBus.base_damaged.emit(team, current_health, max_health)
	_hit_feedback()
	if current_health <= 0:
		destroy()

func destroy() -> void:
	SignalBus.base_destroyed.emit(team)
	Global.declare_game_over(1 - team)

func get_team() -> int:
	return team

func is_dead() -> bool:
	return current_health <= 0

func _hit_feedback() -> void:
	if not visual:
		return
	var tween = create_tween()
	tween.tween_property(visual, "color", Color.WHITE, 0.05)
	tween.tween_property(visual, "color", (
		Color(0.2, 0.5, 0.9) if team == Global.PLAYER_TEAM else Color(0.9, 0.2, 0.2)
	), 0.1)
