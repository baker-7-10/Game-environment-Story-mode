extends Node

func _ready() -> void:
	SignalBus.gold_changed.connect(_on_gold_changed)

func _on_gold_changed(team: int, amount: int) -> void:
	pass
