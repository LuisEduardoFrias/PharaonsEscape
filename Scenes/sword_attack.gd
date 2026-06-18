# SwordAttackState.gd
extends StateBase

func enter(_data: Dictionary = {}) -> void:
	parameter = "parameters/sword_attack/BlendSpace2D/blend_position"

	change_animation()
	actor.playback.travel("sword_attack")
