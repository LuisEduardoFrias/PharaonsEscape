# FiniteStateMachine.gd
class_name StateMachine extends Node

@export var initial_state: StateBase

var current_state: StateBase

var states: Dictionary = {}


func _ready() -> void:
	await owner.ready

	for child in get_children():
		if child is StateBase:
			states[child.name.to_lower()] = child
			child.transitioned.connect(on_child_transition)
			child.actor = owner as Entity

	if initial_state:
		initial_state.enter()
		current_state = initial_state


func _process(delta: float) -> void:
	if current_state: current_state.update(delta)


func _physics_process(delta: float) -> void:
	if current_state: current_state.physics_update(delta)


func _input(event: InputEvent) -> void:
	if current_state: current_state.input(event)


func on_child_transition(new_state_name: String, data: Dictionary = {}) -> void:
	var new_state: StateBase = states.get(new_state_name.to_lower())
	if !new_state or new_state == current_state:
		return

	if current_state:
		current_state.exit()

	new_state.enter(data)
	current_state = new_state
