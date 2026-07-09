extends "res://scripts/units/states/State.gd"

var mine_timer: float = 0.0
var _mine_index: int = -1
const MINE_TIME: float = 2.0
const GOLD_PER_MINE: int = 10

func _ready() -> void:
	super._ready()

func enter(msg: Dictionary = {}) -> void:
	mine_timer = 0.0
	_mine_index = msg.get("mine_index", unit.mine_index if unit else -1)
	if unit:
		unit.mine_index = _mine_index
		if _mine_index >= 0:
			Global.get_miners_at_mine(unit.team, _mine_index).append(unit)

func exit() -> void:
	if unit and _mine_index >= 0:
		Global.get_miners_at_mine(unit.team, _mine_index).erase(unit)

func update(delta: float) -> void:
	if not unit:
		return
	mine_timer += delta
	if mine_timer >= MINE_TIME:
		mine_timer = 0.0
		unit.gold_carried += GOLD_PER_MINE
		unit.state_machine.change_to("miner_move", {"destination": unit.get_base_position()})

	unit.velocity = Vector2.ZERO

func physics_update(_delta: float) -> void:
	if unit:
		unit.move_and_slide()
