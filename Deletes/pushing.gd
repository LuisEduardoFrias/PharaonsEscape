# PushingState.gd
extends StateBase

var direction: Vector2


func enter(data: Dictionary = {}) -> void:
	super()
	parameter = "parameters/pulling/BlendSpace2D/blend_position"

	direction = data.direction
	change_animation()
	actor.playback.travel("pulling")


func physics_update(_delta: float) -> void:
	if actor.current_direction != direction:
		transitioned.emit("idle")
