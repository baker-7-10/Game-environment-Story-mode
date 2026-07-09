extends Node

# Central signal bus — decouples all game systems.
# Systems emit and listen here instead of reaching into each other.
# Pattern: any node can connect to SignalBus.<signal_name>.connect(...)

signal gold_changed(team: int, amount: int)
signal unit_spawned(team: int, unit: Node2D, type: String)
signal unit_died(team: int, unit: Node2D)
signal unit_deposited_gold(team: int, amount: int)
signal base_damaged(team: int, health: float, max_health: float)
signal base_destroyed(team: int)
signal game_over(winner: int)
signal game_restarted()
