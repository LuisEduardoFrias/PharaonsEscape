extends EnemyBase


func post_idle() -> void:
	anim.play("post_idle")


func attacking_1() -> void:
	print("patrullar")
	anim.play("attacking_1")


## Maneja la patrulla cíclica ida y vuelta.
func handle_patrol() -> void:
	if is_waiting:
		velocity = Vector2.ZERO
		return

	var current_destination: Vector2 = patrol_target_position if moving_to_target else start_patrol_position
	var distance_to_dest: float = global_position.distance_to(current_destination)

	if distance_to_dest <= 5.0:
		start_idle_wait()
		return


	if state_machine:
		state_machine._on_child_transition(AnimationEnemyStateMachine.States.WALK)
		await Util.timerout(1.0)

	var move_dir: Vector2 = global_position.direction_to(current_destination)
	velocity = move_dir * speed
	update_direction(move_dir)
	play_sound(walk_sfx, 80.0, 1.0, false)
