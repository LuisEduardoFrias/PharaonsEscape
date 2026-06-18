# State.gd
class_name StateBase extends Node

# Esta señal silve para poder cambiar estados desde los mismo estados
@warning_ignore("unused_signal")
signal transitioned(state: String, data: Dictionary)

var parameter : String

var actor: Entity:
	set(val):
		actor = val
		actor.is_static_state.connect(
			func (value:bool) -> void:
				set_physics_process(!value)
				set_process(!value)
				set_process_input(!value)
		)


func enter(_data: Dictionary = {}) -> void:
	set_physics_process(false)
	set_process(false)
	set_process_input(false)

func exit() -> void:
	set_physics_process(false)
	set_process(false)
	set_process_input(false)

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func input(_event: InputEvent) -> void:
	pass

func change_animation() -> void:
	if actor.old_direction != Vector2.ZERO:
		actor.animation_tree.set(parameter, actor.old_direction)
