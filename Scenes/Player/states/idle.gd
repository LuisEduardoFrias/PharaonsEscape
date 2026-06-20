# IDOE STATE
extends StateBase

var pre_state: String = ""

func enter(_data: Dictionary = {}) -> void:
	super()

	parameter = "parameters/idle/BlendSpace/blend_position"
	actor.current_state = Player.States.IDLE
	actor.playback.travel("idle")
	change_animation()

	if not actor.playback.state_started.is_connected(started_animation):
		actor.playback.state_started.connect(started_animation)


func started_animation(state: StringName) -> void:
	if pre_state == "sword_attack" and state == "idle":
		transitioned.emit(state, {})
	if pre_state == "hammer_attack" and state == "idle":
		transitioned.emit(state, {})
	if pre_state == "interact" and state == "idle":
		transitioned.emit(state, {})
	if pre_state == "roll" and state == "idle":
		transitioned.emit(state, {})
	if pre_state == "hurt" and state == "idle":
		transitioned.emit(state, {})

	pre_state = state


func physics_update(_delta: float) -> void:
	if actor.current_direction != Vector2.ZERO and not actor.ray.is_colliding():
		transitioned.emit("walk", {})


func input(_event: InputEvent) -> void:
	if _event.is_action_pressed(&"ui_action_1") and actor.interactive_obj:
		transitioned.emit("interactive", {})
	elif not actor.is_jumping and _event.is_action_pressed(&"ui_action_1") and not actor.interactive_obj:
		transitioned.emit("jump", {})
