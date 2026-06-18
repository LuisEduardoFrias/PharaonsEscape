class_name Player extends Entity

enum States { WALK, IDLE }

@onready var shadow: Sprite2D = $shadow

signal is_static_state(value: bool)

var current_state: States = States.IDLE

const TARGET_DIR_RAY: Vector2 = Vector2(13.0, 8.0)


func _ready() -> void:
	super()


func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	if direction.length() < 0.5:
		direction = Vector2.ZERO

	current_direction = direction
	ray.target_position = (direction * TARGET_DIR_RAY)

	if direction != Vector2.ZERO:
		old_direction = direction.normalized()
		velocity = old_direction * speed
	else:
		velocity = Vector2.ZERO

	if old_direction.x > 0: sprite_node.flip_h = true
	else: sprite_node.flip_h = false

	move_and_slide()


#Detiene todo
func input_physics_off(val):
	set_physics_process(!val)
	set_process_input(!val)
	is_static_state.emit(val)

	if val:
		velocity = Vector2.ZERO
		move_and_slide()


# Método para cinematica de movimientos en Top-Down
func _move_to(dir: Vector2, move_time: float) -> void:
	input_physics_off(true)
	current_direction = dir
	old_direction = dir

	if not is_node_ready():
		await ready


	# Bucle de emulación de movimiento por tiempo fijo a velocidad constante
	var time: float = 0.0

	while time < move_time:
		var delta: float = get_physics_process_delta_time()

		if dir.x > 0: sprite_node.flip_h = true
		else: sprite_node.flip_h = false

		velocity = current_direction * speed
		move_and_slide()

		if playback.get_current_node() != "walk":
			playback.travel("walk")
			state_machine.on_child_transition("walk")

		time += delta
		await get_tree().physics_frame

	velocity = Vector2.ZERO
	move_and_slide()

	current_direction = Vector2.ZERO
