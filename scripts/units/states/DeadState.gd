extends "res://scripts/units/states/State.gd"

func _ready() -> void:
	super._ready()

func enter(_msg: Dictionary = {}) -> void:
	if not unit:
		return
	unit.collision_layer = 0
	unit.collision_mask = 0
	if unit.has_node("AttackRange"):
		unit.get_node("AttackRange").monitoring = false

	var tween = unit.create_tween()
	tween.set_parallel(true)
	tween.tween_property(unit, "modulate:a", 0.0, 0.6)
	tween.tween_property(unit, "rotation", deg_to_rad(90 * sign(unit.look_direction)), 0.5)
	tween.tween_property(unit, "position:y", unit.position.y + 20, 0.6)
	tween.finished.connect(func():
		SignalBus.unit_died.emit(unit.team, unit)
		unit.queue_free()
	)
	unit.velocity = Vector2.ZERO

func physics_update(_delta: float) -> void:
	if unit:
		unit.move_and_slide()
