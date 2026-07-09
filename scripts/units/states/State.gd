class_name State
extends Node

# Base state for the reusable FSM.
# Each state defines enter/exit hooks and update/physics_update logic.
# States access the owning unit via `owner` (set by StateMachine).

var unit: Node2D

func _ready() -> void:
	await owner.ready
	unit = owner

func enter(_msg: Dictionary = {}) -> void:
	pass

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass
