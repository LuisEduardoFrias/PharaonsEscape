# IDLE STATE
extends StateBase


func enter(_data: Dictionary = {}) -> void:
	super()
	#actor._input_physics_off(false)


func physics_update(_delta: float) -> void:
	if actor.current_direction != Vector2.ZERO and not actor.ray.is_colliding():
		change_state.emit(AnimationStateMachine.States.WALK, {})


func input(event: InputEvent) -> void:
	actor.input(self, event)
