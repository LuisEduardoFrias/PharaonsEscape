# RollState.gd
extends StateBase

var tween: Tween = null

func enter(_data: Dictionary = {}) -> void:
	super()
	set_physics_process(true)
	tween = create_tween()

	actor.input_physics_off(true)

	if actor.wall_gap and actor.wall_gap is WallGapRoll:
		actor.wall_gap.open()

	var _position: Vector2 = actor.global_position + (140.0 * actor.old_direction)
	tween.tween_property(actor, ^"global_position", _position, 1.0)


func _physics_process(_delta: float) -> void:
	actor.ray.force_raycast_update()
	if (actor as Player).ray.is_colliding() and tween != null:
		tween.kill()
		change_state.emit("idle")
	elif not is_physics_processing():
		set_physics_process(true)
