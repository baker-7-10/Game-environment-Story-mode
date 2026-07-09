extends Node2D

@export var team: int = 0
@export var max_health: float = 500.0

var current_health: float
var _camera: Node

@onready var health_bar: Node2D = $HealthBar
@onready var visual: Polygon2D = $Sprite2D
@onready var banner: Polygon2D = $Banner

func _ready() -> void:
	current_health = max_health
	_camera = get_tree().current_scene.get_node("Camera")
	if team == Global.PLAYER_TEAM:
		visual.color = Color(0.15, 0.4, 0.8)
		banner.color = Color(0.3, 0.6, 1.0)
	else:
		visual.color = Color(0.8, 0.15, 0.15)
		banner.color = Color(1.0, 0.3, 0.3)

func _process(_delta: float) -> void:
	if health_bar and health_bar.has_method("update_value"):
		health_bar.update_value(current_health / max_health)

func take_damage(amount: float, _source: Node2D = null) -> void:
	current_health = max(0.0, current_health - amount)
	SignalBus.base_damaged.emit(team, current_health, max_health)

	Global.apply_hit_stop(0.12)
	_hit_feedback()

	if _camera and _camera.has_method("shake"):
		var health_pct = current_health / max_health
		var intensity = lerpf(8.0, 20.0, 1.0 - health_pct)
		_camera.shake(intensity, 0.35)

	var sound_mgr = get_tree().current_scene.get_node("SoundManager") if get_tree().current_scene else null
	if sound_mgr and sound_mgr.has_method("play_base_alarm"):
		sound_mgr.play_base_alarm()

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
	var c = Color(0.15, 0.4, 0.8) if team == Global.PLAYER_TEAM else Color(0.8, 0.15, 0.15)
	var bc = Color(0.3, 0.6, 1.0) if team == Global.PLAYER_TEAM else Color(1.0, 0.3, 0.3)
	var t = create_tween()
	t.tween_property(visual, "color", Color.WHITE, 0.05)
	t.tween_property(visual, "color", c, 0.1)
	var t2 = create_tween()
	t2.tween_property(banner, "color", Color.WHITE, 0.05)
	t2.tween_property(banner, "color", bc, 0.1)
