class_name Pushable extends Node2D

@onready var ray: RayCast2D = $ray_cast
@onready var collision_top: CollisionShape2D = $top/collision_top
@onready var collision_right: CollisionShape2D = $right/collision_right
@onready var collision_down: CollisionShape2D = $down/collision_down
@onready var collision_left: CollisionShape2D = $left/collision_left

@export var init_pushable: float = 0.4

var tile_size := 32
var is_moving := false
var allow_impact := false
var direction := Vector2.ZERO
var timer := 0.0
var player: Player = null

signal moving
signal impact

func _ready() -> void:
	ray.add_exception_rid(owner)


func _physics_process(delta: float) -> void:
	if player:
		ray.add_exception(player)
		#ray.add_exception(player.static_body_player)
		timer += delta

		var control_direction : Vector2 = player.current_direction

		if not direction.is_equal_approx(control_direction):
			timer = 0.0
			return

		if timer >= init_pushable:
			timer = 0.0
			push()


func push() -> void:
	if player:
		player.state_machine.on_child_transition("pulling", { "direction": direction } )
	disabled()
	verify_collition()


func verify_collition() -> void:
	if direction != Vector2.ZERO and is_moving == false:
		ray.target_position = direction * 20

		ray.force_raycast_update()

		if !ray.is_colliding():
			moving.emit()
			move_box(owner.global_position + (direction * tile_size))
		elif allow_impact:
			allow_impact = false
			impact.emit()
			direction = Vector2.ZERO
			disabled(false)
		else:
			disabled(false)


func move_box(target_pos: Vector2) -> void:
	allow_impact = true
	is_moving = true

	var tween : Tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.tween_property(owner, "global_position", target_pos, 0.25)
	await tween.finished

	is_moving = false
	verify_collition()


func _on_top_body_entered(body: Node2D) -> void:
	if body is Player:
		set_direction(Vector2.DOWN, body)
func _on_right_body_entered(body: Node2D) -> void:
	if body is Player:
		set_direction(Vector2.LEFT, body)
func _on_down_body_entered(body: Node2D) -> void:
	if body is Player:
		set_direction(Vector2.UP, body)
func _on_left_body_entered(body: Node2D) -> void:
	if body is Player:
		set_direction(Vector2.RIGHT, body)


func set_direction(direc: Vector2, body: Node2D) -> void:
	player = body
	set_physics_process(true)
	direction = direc


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		player = null
		set_physics_process(false)


func disabled(value: bool = true) -> void :
	collision_top.set_deferred("disabled", value)
	collision_right.set_deferred("disabled", value)
	collision_down.set_deferred("disabled", value)
	collision_left.set_deferred("disabled", value)
