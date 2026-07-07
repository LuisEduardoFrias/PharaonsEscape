# State.gd
class_name StateBase extends Node

# Esta señal silve para poder cambiar estados desde los mismo estados
@warning_ignore("unused_signal")
signal change_state(state: AnimationStateMachine.States, data: Dictionary)

var parent: AnimationStateMachine
var actor: Entity


func enter(_data: Dictionary = {}) -> void:
	parent = get_parent()
	parent.animation_direction(actor.old_direction)


func exit() -> void:
	pass


func update(_delta: float) -> void:
	pass

	parent.animation_direction(actor.current_direction)


func physics_update(_delta: float) -> void:
	pass


func input(_event: InputEvent) -> void:
	pass
