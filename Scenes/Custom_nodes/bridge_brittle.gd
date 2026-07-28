extends Sprite2D

signal brittle

@export_file("*.tscn") var next_scene: String = "":
	set(val):
		if Engine.is_editor_hint() and val == "":
			printerr("[Custom Error]: El SceneTrigger: "+ name + ", no tiene una escena de destino asignada.")
		next_scene = val

@onready var bridge: Area2D = $bridge


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		fall(body)


func animate_bridge_collapse() -> Signal:
	var tw:Tween = create_tween()
	tw.tween_property(self, ^"frame", 14, 1.0)
	brittle.emit()
	return tw.finished


func _on_bridge_body_entered(body: Node2D) -> void:
	if body is Player:
		body.in_bridge = true


func _on_bridge_body_exited(body: Node2D) -> void:
	if body is Player:
		body.in_bridge = false


func fall(player: Player) -> void:
	player._input_physics_off(true)
	await Util.timerout(1.0)
	player.show_quetion(true)
	await Util.timerout(1.0)
	await animate_bridge_collapse()

	player.state_machine._on_child_transition(AnimationStateMachine.States.FALL)
	await player.state_machine.animation_finished

	SceneLoader.level_change("drop", Vector2.ZERO)
	owner.change_scene_screen.transition_out()
	await get_tree().physics_frame
	await get_tree().physics_frame
	#SceneLoader.change_scene(next_scene)
