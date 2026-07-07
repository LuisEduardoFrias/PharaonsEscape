# IDLE STATE
extends StateBase


func enter(_data: Dictionary = {}) -> void:
	super()


func physics_update(_delta: float) -> void:
	if actor.current_direction != Vector2.ZERO and not actor.ray.is_colliding():
		change_state.emit(AnimationStateMachine.States.WALK, {})


func input(_event: InputEvent) -> void:
	if actor.is_control_off:
		return

	if _event.is_action_pressed(&"ui_action_1"):
		if actor.interactive_object:
			change_state.emit(AnimationStateMachine.States.INTERACT, {})
		elif not actor.is_jumping:
			change_state.emit(AnimationStateMachine.States.JUMP, {})
		return
	if _event.is_action_pressed(&"ui_action_2"):
		change_state.emit(AnimationStateMachine.States.SWORD_ATTACK, {})
