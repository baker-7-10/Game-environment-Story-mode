extends Node

@export var initial_state: String = "idle"

var current_state: Node
var states: Dictionary = {}
var _state_script: GDScript

func _ready() -> void:
	_state_script = preload("res://scripts/units/states/State.gd")
	for child in get_children():
		if child.get_script() and _is_state_script(child.get_script()):
			states[child.name.to_lower()] = child
	if states.has(initial_state):
		change_to(initial_state)

func _is_state_script(script: GDScript) -> bool:
	var s = script
	while s:
		if s == _state_script:
			return true
		s = s.get_base_script()
	return false

func _process(delta: float) -> void:
	if current_state and current_state.has_method("update"):
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state and current_state.has_method("physics_update"):
		current_state.physics_update(delta)

func change_to(state_name: String, msg: Dictionary = {}) -> void:
	var new_state: Node = states.get(state_name.to_lower())
	if new_state == null:
		push_warning("StateMachine: unknown state ", state_name)
		return
	if current_state and current_state.has_method("exit"):
		current_state.exit()
	current_state = new_state
	if current_state and current_state.has_method("enter"):
		current_state.enter(msg)
