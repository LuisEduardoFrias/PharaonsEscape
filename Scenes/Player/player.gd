class_name Player extends Entity

@onready var shadow: Sprite2D = $shadow
@onready var effect: AnimatedSprite2D = $effects
@onready var floor_detected: Area2D = $floor_detected #area para detectar cosas en el suelo
@onready var shadow2: LightOccluder2D = $LightOccluder2D
@onready var eye_horus: EyeHorus = $eye_of_horus
@onready var hit: Area2D = $hit

@export_group("Visuals & Audio")
@export var wark_sfx: AudioStream
@export var jump_sfx: AudioStream
@export var sword_attack_sfx: AudioStream
@export var hammer_attack_sfx: AudioStream


signal is_static_state(value: bool)

var interactive_object: Variant = null
var spawner_point: Vector2 = Vector2.LEFT
var is_jumping: bool = false # Para validar si está en faltando
var is_eye_horus_enable: bool = false # Verifica si está activada la habilidad del ojo de horus
var is_control_off: bool = false

const TARGET_DIR_RAY: Vector2 = Vector2(13.0, 8.0)


func _ready() -> void:
	super()
	floor_detected.body_entered.connect(_floor_detected_body_entered)


func _physics_process(_delta: float) -> void:
	if ! is_control_off:
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

		if old_direction.x > 0:
			sprite_node.flip_h = true
			hit.scale = Vector2(-1.0, 1.0)
		else:
			sprite_node.flip_h = false
			hit.scale = Vector2(1.0, 1.0)

		move_and_slide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_action_2") :
		pass#eye_horus._enable_eje_horus()


#Detiene todas las entradas al player
func _input_physics_off(val):
	set_physics_process(!val)
	set_process_input(!val)
	is_control_off = val
	is_static_state.emit(val)

	if val:
		velocity = Vector2.ZERO
		move_and_slide()


# Método para cinematica de movimientos en Top-Down
func _move_to(dir: Vector2, move_time: float) -> void:
	_input_physics_off(true)
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

		if state_machine.animation_name != "walk":
			state_machine._on_child_transition(AnimationStateMachine.States.WALK)

		time += delta
		await get_tree().physics_frame

	velocity = Vector2.ZERO
	move_and_slide()

	current_direction = Vector2.ZERO


## Método que hace que el Player sea intermitente por un periodo de tiempo
func intermittency(duration: float = 1.0, callback: Callable = Callable()) -> void:
	var tw: Tween = create_tween().set_loops()

	tw.tween_property(self, "modulate:a", 0.0, 0.1)
	tw.tween_property(self, "modulate:a", 1.0, 0.1)

	await get_tree().create_timer(duration).timeout

	tw.kill()
	modulate.a = 1.0
	if callback.is_valid(): callback.call_deferred()


## Método que silve para interacion con cosas en el piso
func _floor_detected_body_entered(body: Node2D) -> void:
	if body as TileMapLayer:
		_tile_hit(body)
		return


## Método que silve para interacion con Tiles que hacen daño
func _tile_hit(_body: TileMapLayer) -> void:
	#hacer daño y spawner
	_input_physics_off(true)
	state_machine._on_child_transition(AnimationStateMachine.States.FALL)
	await state_machine.animation_finished
	position = spawner_point
	intermittency()
	state_machine._on_child_transition(AnimationStateMachine.States.IDLE)
	await Util.timerout(0.5)
	owner.change_platform()
	_input_physics_off(false)


func add_skill_effect(h_effect: bool) -> void:
	effect.play(&"add_skill_horizontal" if h_effect else &"add_skill_vertical")
