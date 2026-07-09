extends "res://scripts/units/states/State.gd"

func _ready() -> void:
	super._ready()

func enter(_msg: Dictionary = {}) -> void:
	if not unit:
		return
	if unit.gold_carried > 0:
		Global.modify_gold(unit.team, unit.gold_carried)
		SignalBus.unit_deposited_gold.emit(unit.team, unit.gold_carried)
		unit.gold_carried = 0
	unit.state_machine.change_to("miner_move", {"destination": unit.get_mine_position()})

func update(_delta: float) -> void:
	if unit:
		unit.velocity = Vector2.ZERO

func physics_update(_delta: float) -> void:
	if unit:
		unit.move_and_slide()
