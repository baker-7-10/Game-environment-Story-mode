extends Node

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
