extends Area2D

@export_file_path() var escene_boss_fight: String


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body._input_physics_off(true)
		body.current_direction = Vector2.ZERO
		await Util.timerout(1.0)
		body.show_quetion(true)
		await Util.timerout(1.0)
		body.old_direction = Vector2.DOWN
		await Util.timerout(1.0)
		body.state_machine._on_child_transition(AnimationStateMachine.States.IDLE)
		await Util.timerout(1.0)
		await owner.vortex.transition_in()
		body.show_quetion(false)
		SceneLoader.change_scene(escene_boss_fight)
