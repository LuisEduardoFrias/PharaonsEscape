# JumpState.gd
extends StateBase

var default_shadow_scale: Vector2 = Vector2(0.280, 0.095)
var mini_shadow_scale: Vector2 = Vector2(0.185, 0.070)

func enter(_data: Dictionary = {}) -> void:
	if actor.is_jumping:
		change_state.emit(AnimationStateMachine.States.IDLE, {})
		return
	else :
		actor.floor_detected.monitoring = false
		actor.is_jumping = true

	super()
	_move_sprite()
	await actor._move_to(actor.old_direction ,0.8)


func physics_update(_delta: float) -> void:
	pass


func _move_sprite() -> void:
	var py = actor.sprite_node.position.y
	var sy = actor.shadow2.position.y
	var tw: Tween = create_tween()

	tw.tween_property(actor.sprite_node, ^"position:y", py - 30.0, 0.4)
	tw.parallel().tween_property(actor.shadow2, ^"position:y", sy - 30.0, 0.4)
	tw.parallel().tween_property(actor.shadow, ^"scale", mini_shadow_scale , 0.4)

	tw.tween_property(actor.sprite_node, ^"position:y", py, 0.4)
	tw.parallel().tween_property(actor.shadow2, ^"position:y", sy, 0.4)
	tw.parallel().tween_property(actor.shadow, ^"scale", default_shadow_scale , 0.3)

	tw.tween_callback(func () -> void:
		change_state.emit(AnimationStateMachine.States.IDLE, {})
		actor._input_physics_off(false)
		actor.floor_detected.monitoring = true
		actor.is_jumping = false
	)
