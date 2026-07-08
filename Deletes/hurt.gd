# HurtState.gd
extends StateBase


func enter(data: Dictionary = {}) -> void:
	parameter = "parameters/hurt/BlendSpace2D/blend_position"

	actor.allow_hurt = false
	change_animation()
	actor.playback.travel("hurt")
	actor.live.hurt(data.damage)
	actor.input_physics_off(true)

	var tw: Tween = create_tween()
	tw.tween_property(actor, "position", data.ps - (32.0 * actor.old_direction), 0.1)
	tw.tween_callback(func () -> void:
		actor.intermittency(1.5,
			func () -> void:
				actor.allow_hurt = true
		)
	)
