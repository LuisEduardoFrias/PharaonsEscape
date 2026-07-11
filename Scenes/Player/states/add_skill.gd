# ADD_SKILL STATE
extends StateBase

func enter(_data: Dictionary = {}) -> void:
	super()
	if actor.current_direction == Vector2.UP:
		actor.old_direction = Vector2.DOWN
