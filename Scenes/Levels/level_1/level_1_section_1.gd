extends SectionBase

func _ready() -> void:
	super()
	#change_scene_screen.transition_out(0.0)

	if Global.bridge_fall:
		Global.bridge_fall = false
		player.state_machine.playback.travel("stop_invisible")
		player._input_physics_off(true)

		await get_tree().physics_frame

		change_scene_screen.transition_in(4.0)
		await Util.timerout(1.0)
		player.state_machine.playback.travel("fall_bridge")
		await player.state_machine.animation_finished
		player.state_machine._on_child_transition(AnimationStateMachine.States.IDLE)
		player._input_physics_off(false)
