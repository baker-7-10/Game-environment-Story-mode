class_name MineState
extends State

# Miner stays at the gold mine, gathering gold over time.
# After gathering enough, returns to base to deposit.

var mine_timer: float = 0.0
const MINE_TIME: float = 2.0
const GOLD_PER_MINE: int = 10

func enter(_msg: Dictionary = {}) -> void:
	mine_timer = 0.0

func update(delta: float) -> void:
	mine_timer += delta
	if mine_timer >= MINE_TIME:
		mine_timer = 0.0
		unit.gold_carried += GOLD_PER_MINE
		unit.state_machine.change_to("miner_move", {"destination": unit.get_base_position()})

	unit.velocity = Vector2.ZERO

func physics_update(_delta: float) -> void:
	unit.move_and_slide()
