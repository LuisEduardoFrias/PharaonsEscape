@tool
extends Path2D

@onready var platform: PathFollow2D = $PathFollow2D

@export_range(0.0, 1.0, 0.01) var progress: float = 0.0:
	set(val):
		progress = val
		if not is_node_ready(): await ready
		platform.progress_ratio = val

@export var play: bool = false:
	set(val):
		play = val
		if is_node_ready():
			setup_tween()

@export var time_move: float = 2.0
@export var time_stop: float = 0.5

var tw: Tween
var player: Player

var last_platform_post: Vector2 = Vector2.ZERO


func _ready() -> void:
	set_process(false)
	setup_tween()


func setup_tween() -> void:
	if Engine.is_editor_hint():
		return

	if tw and tw.is_valid():
		tw.kill()

	if play:
		progress = 0.0
		tw = create_tween().set_loops().bind_node(self)

		tw.tween_interval(time_stop)
		tw.tween_property(self, ^"progress", 1.0, time_move)
		tw.tween_interval(time_stop)
		tw.tween_property(self, ^"progress", 0.0, time_move)


func _process(_delta: float) -> void:
	if player:
		var platform_displacement: Vector2 = platform.global_position - last_platform_post
		player.global_position += platform_displacement

	last_platform_post = platform.global_position


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		if body.is_jumping: body.jump_finished.connect(flatform)
		body.on_platform = true
		player = body
		last_platform_post = platform.global_position
		set_process(true)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		if body.jump_finished.is_connected(flatform): body.jump_finished.disconnect(flatform)
		body.on_platform = false
		set_process(false)
		player = null


func flatform() -> void:
	player.on_platform = true
