# RollState.gd
extends StateBase

var tween: Tween = null

func enter(_data: Dictionary = {}) -> void:
	super()
	actor.target_dir_ray = Vector2(17.0, 12.0)
	set_physics_process(true)
	actor._input_physics_off(true)

	tween = create_tween()

	if actor.wall_gap:
		actor.wall_gap._open()

	var _position: Vector2 = actor.global_position + (140.0 * actor.old_direction)
	tween.tween_property(actor, ^"global_position", _position, 1.0)


func physics_update(_delta: float) -> void:
	actor.ray.force_raycast_update()
	if (actor as Player).ray.is_colliding() and tween != null:
		tween.kill()
		change_state.emit(AnimationStateMachine.States.IDLE)
	elif not is_physics_processing():
		set_physics_process(true)


func exit() -> void:
	actor.target_dir_ray = Vector2(13.0, 8.0)
