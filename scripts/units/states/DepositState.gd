extends "res://scripts/units/states/State.gd"

func _ready() -> void:
	super._ready()

func enter(_msg: Dictionary = {}) -> void:
	if not unit:
		return
	if unit.gold_carried > 0:
		Global.modify_gold(unit.team, unit.gold_carried)
		SignalBus.unit_deposited_gold.emit(unit.team, unit.gold_carried)
		var sound_mgr = get_tree().current_scene.get_node("SoundManager") if get_tree().current_scene else null
		if sound_mgr and sound_mgr.has_method("play_gold_deposit"):
			sound_mgr.play_gold_deposit()
		unit.gold_carried = 0
	unit.state_machine.change_to("miner_move", {"destination": unit.get_mine_position(), "mine_index": unit.mine_index})

func update(_delta: float) -> void:
	if unit:
		unit.velocity = Vector2.ZERO

func physics_update(_delta: float) -> void:
	if unit:
		unit.move_and_slide()
