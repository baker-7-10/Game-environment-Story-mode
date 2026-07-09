class_name AttackState
extends State

# Unit attacks its current target on cooldown.
# Transitions to MoveState if target moves out of range, IdleState if target dies.

func update(_delta: float) -> void:
	if not unit.target or not unit.target_is_valid():
		unit.target = null
		unit.state_machine.change_to("idle")
		return

	var dist = unit.global_position.distance_to(unit.target.global_position)
	if dist > unit.stats.attack_range * 1.1:
		unit.state_machine.change_to("move")
		return

	if unit.can_attack():
		unit.perform_attack()

	unit.velocity = Vector2.ZERO

func physics_update(_delta: float) -> void:
	unit.move_and_slide()
