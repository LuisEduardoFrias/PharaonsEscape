# INTERACT STATE
extends StateBase
func enter(_data: Dictionary = {}) -> void:
	super()
	actor.interactive_object._interact({ "player":actor })
