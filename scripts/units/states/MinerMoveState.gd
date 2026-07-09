extends "res://scripts/units/states/State.gd"

var destination: Vector2
var target_mine_index: int = -1

func enter(msg: Dictionary = {}) -> void:
	destination = msg.get("destination", unit.global_position if unit else Vector2())
	target_mine_index = msg.get("mine_index", -1)

func _get_mine_index_at_dest() -> int:
	if not unit:
		return -1
	var mine_positions = unit.get_mine_positions()
	for idx in range(mine_positions.size()):
		if destination.distance_to(mine_positions[idx]) < 5.0:
			return idx
	return -1

func update(_delta: float) -> void:
	if not unit:
		return
	var dist = unit.global_position.distance_to(destination)
	if dist < 10.0:
		var mine_idx = _get_mine_index_at_dest()
		if mine_idx >= 0:
			if Global.get_miners_at_mine_count(unit.team, mine_idx) < Global.MAX_MINERS_PER_MINE:
				unit.state_machine.change_to("mine", {"mine_index": mine_idx})
			else:
				unit.velocity = Vector2.ZERO
		else:
			unit.state_machine.change_to("deposit")
		return

	var dir = (destination - unit.global_position).normalized()
	unit.velocity = dir * unit._stat("move_speed", 80.0)
	unit.look_direction = sign(dir.x)

func physics_update(_delta: float) -> void:
	if unit:
		unit.move_and_slide()
