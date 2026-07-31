extends Sprite2D

@export_file("*.tscn") var next_scene: String = "":
	set(val):
		if Engine.is_editor_hint() and val == "":
			printerr("[Custom Error]: El SceneTrigger: "+ name + ", no tiene una escena de destino asignada.")
		next_scene = val

@onready var bridge: Area2D = $bridge
@onready var actived: Area2D = $actived
@onready var coli: CollisionShape2D = $StaticBody2D/CollisionShape2D3

var is_collapse: bool = false
var middle_colapse: bool = false


func _ready() -> void:
	Global.bridge(LevelsData.Levels.LEVEL3, owner.name, self)


func _interact(data: Dictionary) -> void:
	middle_colapse = data.middle_colapse if data else false
	is_collapse = data.full_colapse
	collapsed()


#activador del colapso
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		fall_collapsed(body)


func animate_bridge_collapse() -> Signal:

	var tw:Tween = create_tween()
	tw.tween_property(self, ^"frame", 14 if middle_colapse and is_collapse else 5, 1.0)
	return tw.finished


func _on_bridge_body_entered(body: Node2D) -> void:
	if body is Player:
		body.in_bridge = true
		if ! body.fall.is_connected(change_scene): body.fall.connect(change_scene)
		if is_collapse:
			Util.timerout(0.2)
			body.in_bridge = false


func _on_bridge_body_exited(body: Node2D) -> void:
	if body is Player:
		body.in_bridge = false


func fall_collapsed(player: Player) -> void:
	coli.disabled = !middle_colapse
	is_collapse = middle_colapse
	if middle_colapse:
		actived.queue_free()
		player._input_physics_off(true)
		player.state_machine._cinematic(AnimationStateMachine.States.IDLE)
		await Util.timerout(0.5)
		player.show_quetion(true)
		await Util.timerout(1.0)
	await animate_bridge_collapse()
	if middle_colapse:
		bridge.queue_free()

	Global.bridge(LevelsData.Levels.LEVEL3, owner.name, self, true)


func collapsed() -> void:
	animate_bridge_collapse()

	if is_collapse:
		actived.queue_free()
		$StaticBody2D.queue_free()


func change_scene() -> void:
	SceneLoader.level_change("drop", Vector2.ZERO)
	await owner.change_scene_screen.transition_out()
	await get_tree().physics_frame
	await get_tree().physics_frame
	Global.bridge_fall = true
	SceneLoader.change_scene(next_scene)
