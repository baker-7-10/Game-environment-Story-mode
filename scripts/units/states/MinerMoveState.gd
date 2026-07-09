extends "res://scripts/units/states/State.gd"

var destination: Vector2

func enter(msg: Dictionary = {}) -> void:
	destination = msg.get("destination", unit.global_position if unit else Vector2())

func update(_delta: float) -> void:
	if not unit:
		return
	var dist = unit.global_position.distance_to(destination)
	if dist < 10.0:
		if destination == unit.get_mine_position():
			unit.state_machine.change_to("mine")
		else:
			unit.state_machine.change_to("deposit")
		return

	var dir = (destination - unit.global_position).normalized()
	unit.velocity = dir * unit._stat("move_speed", 80.0)
	unit.look_direction = sign(dir.x)

func physics_update(_delta: float) -> void:
	if unit:
		unit.move_and_slide()
