extends Unit

func _ready() -> void:
	super._ready()
	visual.color = Color(1.0, 0.85, 0.3) if team == Global.PLAYER_TEAM else Color(0.8, 0.5, 0.2)
	state_machine.change_to("miner_move", {"destination": get_mine_position()})

func acquire_target() -> void:
	pass

func perform_attack() -> void:
	pass
