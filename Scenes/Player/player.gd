extends CharacterBody2D

const MAX_SPEED = 250.0
const ACCELERATION = 1200.0
const FRICTION = 1500.0

const JUMP_VELOCITY = -400.0
const MIN_JUMP_VELOCITY = -150.0
const AIR_CONTROL = 0.7

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_released("ui_accept") and velocity.y < MIN_JUMP_VELOCITY:
		velocity.y = MIN_JUMP_VELOCITY

	var direction := Input.get_axis("ui_left", "ui_right")

	if direction != 0:
		var accel = ACCELERATION if is_on_floor() else ACCELERATION * AIR_CONTROL
		velocity.x = move_toward(velocity.x, direction * MAX_SPEED, accel * delta)
	else:
		var fric = FRICTION if is_on_floor() else FRICTION * AIR_CONTROL
		velocity.x = move_toward(velocity.x, 0, fric * delta)

	move_and_slide()
