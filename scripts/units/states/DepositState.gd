class_name DepositState
extends State

# Miner deposits carried gold into the team's economy.
# Transitions back to mining loop.

func enter(_msg: Dictionary = {}) -> void:
	if unit.gold_carried > 0:
		Global.modify_gold(unit.team, unit.gold_carried)
		SignalBus.unit_deposited_gold.emit(unit.team, unit.gold_carried)
		unit.gold_carried = 0
	unit.state_machine.change_to("miner_move", {"destination": unit.get_mine_position()})

func update(_delta: float) -> void:
	unit.velocity = Vector2.ZERO

func physics_update(_delta: float) -> void:
	unit.move_and_slide()
