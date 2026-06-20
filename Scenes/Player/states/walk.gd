# WalkState.gd
extends StateBase


func enter(_data: Dictionary = {}) -> void:
	super()
	parameter = "parameters/walk/BlendSpace/blend_position"
	actor.current_state = Player.States.WALK

	if actor.get_real_velocity() != Vector2.ZERO:
		actor.playback.travel("walk")

	change_animation()


func physics_update(_delta: float) -> void:
	if actor.current_direction == Vector2.ZERO or actor.ray.is_colliding():
		transitioned.emit("idle", {})
		return

	change_animation()


func input(_event: InputEvent) -> void:
	if _event.is_action_pressed(&"ui_action_1") and actor.interactive_obj:
		transitioned.emit("interactive", {})
	elif not actor.is_jumping and _event.is_action_pressed(&"ui_action_1") and not actor.interactive_obj:
		transitioned.emit("jump", {})
