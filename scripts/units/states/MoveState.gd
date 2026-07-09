class_name MoveState
extends State

# Unit advances toward its target.
# Transitions to AttackState when in range, IdleState if target is lost.

func update(_delta: float) -> void:
	if not unit.target or not unit.target_is_valid():
		unit.target = null
		unit.state_machine.change_to("idle")
		return

	var dist = unit.global_position.distance_to(unit.target.global_position)
	if dist <= unit.stats.attack_range:
		unit.state_machine.change_to("attack")
		return

	var dir = (unit.target.global_position - unit.global_position).normalized()
	unit.velocity = dir * unit.stats.move_speed
	unit.look_direction = sign(dir.x)

func physics_update(_delta: float) -> void:
	unit.move_and_slide()
