# INTERACT STATE
extends StateBase

func enter(_data: Dictionary = {}) -> void:
	actor._input_physics_off(true)
	super()
	actor.interactive_object._interact({ "player":actor })
	'''await parent.animation_finished
	actor._input_physics_off(false)'''
