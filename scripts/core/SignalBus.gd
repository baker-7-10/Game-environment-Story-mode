extends Node

signal gold_changed(team: int, amount: int)
signal unit_spawned(team: int, unit: Node2D, type: String)
signal unit_died(team: int, unit: Node2D)
signal unit_deposited_gold(team: int, amount: int)
signal base_damaged(team: int, health: float, max_health: float)
signal base_destroyed(team: int)
signal game_over(winner: int)
signal game_restarted()
signal army_stance_changed(stance: int)

signal population_changed(team: int, current: int, max_pop: int)
signal rage_changed(team: int, current: float, max_rage: float)
signal rage_activated(team: int, duration: float)
signal rage_deactivated(team: int)
