# SWORD_ATTACK STATE
extends StateBase

func enter(_data: Dictionary = {}) -> void:
	super()
	#actor._input_physics_off(true)


func _on_hit_body_entered(body: Node2D) -> void:
	if body.has_method("hurt"):
		body.hurt(actor.damage)
