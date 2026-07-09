class_name IdleState
extends State

# Unit stands still. Transitions to MoveState if a target is acquired
# and the unit is not already in attack range.

func update(_delta: float) -> void:
	if unit.target and unit.target_is_valid():
		var dist = unit.global_position.distance_to(unit.target.global_position)
		if dist > unit.stats.attack_range:
			unit.state_machine.change_to("move")
	else:
		unit.acquire_target()

func physics_update(_delta: float) -> void:
	unit.velocity = Vector2.ZERO
	unit.move_and_slide()
