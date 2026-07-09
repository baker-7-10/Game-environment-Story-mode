class_name MinerMoveState
extends State

# Miner moves toward the gold mine (or back to base).
# The destination is set by the state machine when transitioning in.

var destination: Vector2

func enter(msg: Dictionary = {}) -> void:
	destination = msg.get("destination", unit.global_position)

func update(_delta: float) -> void:
	var dist = unit.global_position.distance_to(destination)
	if dist < 10.0:
		if destination == unit.get_mine_position():
			unit.state_machine.change_to("mine")
		else:
			unit.state_machine.change_to("deposit")
		return

	var dir = (destination - unit.global_position).normalized()
	unit.velocity = dir * unit.stats.move_speed
	unit.look_direction = sign(dir.x)

func physics_update(_delta: float) -> void:
	unit.move_and_slide()
