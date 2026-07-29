# WalkState.gd
extends StateBase


func enter(_data: Dictionary = {}) -> void:
	super()

	if actor.get_real_velocity() != Vector2.ZERO:
		pass
		#parent._on_child_transition(AnimationStateMachine.States.WALK)


func physics_update(_delta: float) -> void:
	if (actor.current_direction == Vector2.ZERO or actor.ray.is_colliding()) and not actor.is_control_off:
		change_state.emit(AnimationStateMachine.States.IDLE, {})
		return

	parent.animation_direction(actor.current_direction)


func input(event: InputEvent) -> void:
	actor.input(self, event)
