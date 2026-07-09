extends "res://scripts/units/Unit.gd"

func _ready() -> void:
	super._ready()
	var c = Color(1.0, 0.85, 0.3) if team == Global.PLAYER_TEAM else Color(0.8, 0.5, 0.2)
	if visual.has_method("set_body_color"):
		visual.set_body_color(c)
	var idx = Global.get_nearest_available_mine(team, global_position)
	if idx >= 0:
		mine_index = idx
	else:
		mine_index = 1
	var dest = get_mine_positions()[mine_index]
	state_machine.change_to("miner_move", {"destination": dest, "mine_index": mine_index})

func acquire_target() -> void:
	pass

func perform_attack() -> void:
	pass
