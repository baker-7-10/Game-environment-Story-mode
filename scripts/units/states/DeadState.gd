class_name DeadState
extends State

# Plays a procedural death animation (topple + fade), then queues free.
# The Tween approach avoids needing sprite-frame animations.

func enter(_msg: Dictionary = {}) -> void:
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
	unit.move_and_slide()
