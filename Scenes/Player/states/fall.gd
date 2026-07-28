# FALL STATE
extends StateBase

func enter(_data: Dictionary = {}) -> void:
	super()
	parent.animation_started.connect(func (anim_name: StringName) -> void:
		if anim_name == "fall": actor.show_quetion(false))



func physics_update(_delta: float) -> void:
	pass


func input(_event: InputEvent) -> void:
	pass
