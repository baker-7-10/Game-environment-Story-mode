class_name StateMachine
extends Node

# Generic FSM that drives any set of State nodes as children.
# Transition via change_to(state_name, msg_dict).
# The state machine is reused by combat units and miners with different state sets.

@export var initial_state: String = "idle"

var current_state: State
var states: Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
	if states.has(initial_state):
		change_to(initial_state)

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func change_to(state_name: String, msg: Dictionary = {}) -> void:
	var new_state: State = states.get(state_name.to_lower())
	if new_state == null:
		push_warning("StateMachine: unknown state ", state_name)
		return
	if current_state:
		current_state.exit()
	current_state = new_state
	current_state.enter(msg)
