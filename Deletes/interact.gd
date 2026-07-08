# InteractState.gd
extends StateBase


func enter(_data: Dictionary = {}) -> void:
	parameter = "parameters/interact/BlendSpace2D/blend_position"

	actor.playback.travel("interact")
	actor.interactive_object._interact({ "player":actor })

	change_animation()
