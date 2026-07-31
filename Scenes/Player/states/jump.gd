# JumpState.gd
extends StateBase

var default_shadow_scale: Vector2 = Vector2(0.280, 0.095)
var mini_shadow_scale: Vector2 = Vector2(0.185, 0.070)

var jump_force: float = 30.0

func enter(_data: Dictionary = {}) -> void:
	if actor.is_jumping:
		change_state.emit(AnimationStateMachine.States.IDLE, {})
		return
	else :
		actor.set_collision_mask_value(10, false)
		actor.floor_detected.monitoring = false
		actor.floor_detected.monitorable = false
		actor.is_jumping = true
		if actor.side_scroller:
			jump_force = actor.side_scroller.jump_force

	super()
	_move_sprite()
	await actor._move_to(actor.old_direction ,0.8)


func _move_sprite() -> void:
	var py = actor.sprite_node.position.y
	var sy = actor.shadow2.position.y
	var tw: Tween = create_tween()

	tw.tween_property(actor.sprite_node, ^"position:y", py - jump_force, 0.4)
	tw.parallel().tween_property(actor.shadow2, ^"position:y", sy - jump_force, 0.4)
	tw.parallel().tween_property(actor.shadow, ^"scale", mini_shadow_scale , 0.4)

	tw.tween_property(actor.sprite_node, ^"position:y", py, 0.4)
	tw.parallel().tween_property(actor.shadow2, ^"position:y", sy, 0.4)
	tw.parallel().tween_property(actor.shadow, ^"scale", default_shadow_scale , 0.3)

	tw.tween_callback(func () -> void:
		change_state.emit(AnimationStateMachine.States.IDLE, {})
		actor.set_collision_mask_value(10, true)
		actor._input_physics_off(false)
		actor.floor_detected.monitoring = true
		actor.floor_detected.monitorable = true
		actor.is_jumping = false
		actor.jump_finished.emit()
	)
