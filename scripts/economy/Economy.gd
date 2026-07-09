extends Node

# Optional helper for more complex economy logic.
# Currently all gold is managed through Global.modify_gold().
# This node can be extended for interest, income bonuses, or team-specific rates.
class_name Economy

signal gold_changed(team: int, amount: int)

func _ready() -> void:
	SignalBus.gold_changed.connect(_on_gold_changed)

func _on_gold_changed(team: int, amount: int) -> void:
	gold_changed.emit(team, amount)
