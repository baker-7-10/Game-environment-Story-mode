extends "res://scripts/units/states/State.gd"

var mine_timer: float = 0.0
const MINE_TIME: float = 2.0
const GOLD_PER_MINE: int = 10

func _ready() -> void:
	super._ready()

func enter(_msg: Dictionary = {}) -> void:
	mine_timer = 0.0

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
