# InteractState.gd
extends StateBase


func enter(_data: Dictionary = {}) -> void:
	parameter = "parameters/interact/BlendSpace2D/blend_position"

	actor.playback.travel("interact")
	if actor.interactive_obj: actor.interactive_obj.activate({"player":actor})
	if actor.dialogue_trigger: actor.dialogue_trigger.action({"player": actor})

	if actor.old_direction != Vector2.ZERO:
		actor.animation_tree.set(parameter, actor.old_direction)
