@tool extends Node2D

@onready var path_follow: PathFollow2D = $Path2D/PathFollow2D
@export var waiting_time: float = 1.0
@export var speed: float = 1

var direction: int = 1
var on: bool = false
var market_position: Marker2D
var market_angle1: Marker2D
var market_angle2: Marker2D


func _ready() -> void:
	#super()
	$Path2D.curve = $Path2D.curve.duplicate()

	var child_count:int = 0
	for child in get_children():
		if child is Marker2D:
			if child_count == 0: market_position = child
			elif child_count == 1: market_angle1 = child
			else : market_angle2 = child

			child_count += 1

	if Engine.is_editor_hint():
		on = true

	get_tree().create_timer(waiting_time).timeout \
	.connect(func () -> void: on = true, CONNECT_ONE_SHOT)


func _process(delta: float) -> void:
	if not on:
		return

	if market_position:
		$Path2D.curve.set_point_position(1, market_position.position)
	if market_angle1:
		$Path2D.curve.set_point_out(0, market_angle1.position - $Path2D.curve.get_point_position(0))
	if market_angle2:
		$Path2D.curve.set_point_in(1, market_angle2.position - $Path2D.curve.get_point_position(1))


	path_follow.progress_ratio += speed * delta * direction

	if path_follow.progress_ratio >= 1.0:
		path_follow.progress_ratio = 1.0
		direction = -1
	elif path_follow.progress_ratio <= 0.0:
		path_follow.progress_ratio = 0.0
		direction = 1


func _on_hit_area_entered(area: Area2D) -> void:
	if area.get_parent() as Player:
		area.get_parent().hurt($Path2D/PathFollow2D/blade.global_position)
