extends "res://scripts/units/states/State.gd"

func update(_delta: float) -> void:
	if not unit:
		return

	if unit.is_hold_wave():
		unit.velocity = Vector2.ZERO
		return

	if unit.team == Global.PLAYER_TEAM and Global.player_stance == Global.ArmyStance.RETREAT and unit.move_to_position == Vector2(-1, -1):
		unit.state_machine.change_to("move")
		return

	if unit.target and unit.target_is_valid():
		var dist = unit.global_position.distance_to(unit.target.global_position)
		if dist > unit._stat("attack_range", 50.0):
			unit.state_machine.change_to("move")
	else:
		unit.acquire_target()
		if not unit.target and unit.team == Global.PLAYER_TEAM and Global.player_stance == Global.ArmyStance.ADVANCE and unit.move_to_position == Vector2(-1, -1):
			unit.state_machine.change_to("move")

func physics_update(_delta: float) -> void:
	if unit:
		unit.velocity = Vector2.ZERO
		unit.move_and_slide()
