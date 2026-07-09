extends "res://scripts/units/states/State.gd"

func update(_delta: float) -> void:
	if not unit:
		return
	if not unit.target or not unit.target_is_valid():
		unit.target = null
		unit.state_machine.change_to("idle")
		return

	var dist = unit.global_position.distance_to(unit.target.global_position)
	if dist <= unit._stat("attack_range", 50.0):
		unit.state_machine.change_to("attack")
		return

	var dir = (unit.target.global_position - unit.global_position).normalized()
	unit.velocity = dir * unit._stat("move_speed", 100.0)
	unit.look_direction = sign(dir.x)

func physics_update(_delta: float) -> void:
	if unit:
		unit.move_and_slide()
