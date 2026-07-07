# SwordAttackState.gd
extends StateBase

func enter(_data: Dictionary = {}) -> void:
	actor._input_physics_off(true)
	parameter = "parameters/sword_attack/BlendSpace2D/blend_position"
	change_animation()
	actor.playback.travel("sword_attack")
