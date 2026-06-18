class_name CustomCamera extends Camera2D

@export_group("Smooth Follow")
@export var follow_speed: float = 6.0
@export var vertical_offset: float = -8.0

@export_group("Zelda Deadzone")
@export var enable_deadzone: bool = true
@export var deadzone_radius: float = 20.0

@export_group("Anticipation (Look Ahead)")
@export var enable_anticipation: bool = true
@export var anticipation_distance: float = 80.0
@export var anticipation_smoothness: float = 8.0

@export_group("Smart Catch-up")
@export var enable_catch_up: bool = true
@export var catch_up_threshold: float = 100.0

@export_group("Screen Shake")
@export var decay: float = 0.8
@export var max_offset: Vector2 = Vector2(25.0, 25.0)
@export var max_roll: float = 0.03
@export var noise_speed: float = 15.0

var trauma: float = 0.0
var trauma_power: int = 2
var noise: FastNoiseLite = FastNoiseLite.new()
var noise_i: float = 0.0

var virtual_target: Vector2 = Vector2.ZERO
var current_anticipation: Vector2 = Vector2.ZERO

@onready var player: Node2D = get_tree().get_first_node_in_group("Player")


func _ready() -> void:
	noise.seed = randi()
	noise.frequency = 0.15
	position_smoothing_enabled = false

	if player:
		virtual_target = player.global_position + Vector2(0.0, vertical_offset)
		global_position = virtual_target


func _process(delta: float) -> void:
	_follow_target(delta)
	_handle_shake(delta)


## Aplica una cantidad de trauma acumulativo a la cámara.
func add_trauma(amount: float) -> void:
	trauma = min(trauma + amount, 1.0)


## Mantiene un nivel constante de trauma en la cámara ideal para terremotos.
func set_constant_trauma(amount: float) -> void:
	trauma = clamp(amount, 0.0, 1.0)


## Procesa el seguimiento calculando la zona muerta y aplicando la anticipación basada en el desplazamiento real.
func _follow_target(delta: float) -> void:
	if not player:
		player = get_tree().get_first_node_in_group("Player")
		return

	var player_base_target: Vector2 = player.global_position + Vector2(0.0, vertical_offset)
	var previous_virtual_target: Vector2 = virtual_target

	if enable_deadzone:
		var distance_to_player: float = virtual_target.distance_to(player_base_target)
		if distance_to_player > deadzone_radius:
			var overflow: Vector2 = (player_base_target - virtual_target).normalized() * (distance_to_player - deadzone_radius)
			virtual_target += overflow
	else:
		virtual_target = player_base_target

	var target_anticipation: Vector2 = Vector2.ZERO

	if enable_anticipation:
		var target_movement: Vector2 = virtual_target - previous_virtual_target
		if target_movement.length() > 0.01:
			target_anticipation = target_movement.normalized() * anticipation_distance
		else:
			target_anticipation = current_anticipation

	current_anticipation = current_anticipation.lerp(target_anticipation, anticipation_smoothness * delta)
	var final_target_position: Vector2 = virtual_target + current_anticipation

	var current_speed: float = follow_speed
	if enable_catch_up:
		var total_distance: float = global_position.distance_to(final_target_position)
		if total_distance > catch_up_threshold:
			current_speed *= (total_distance / catch_up_threshold) * 1.5

	global_position = global_position.lerp(final_target_position, current_speed * delta)
	global_position = global_position.round()


## Administra la reducción del trauma y aplica la vibración matemática.
func _handle_shake(delta: float) -> void:
	if trauma > 0.0:
		trauma = max(trauma - decay * delta, 0.0)
		_shake(delta)
	else:
		offset = offset.lerp(Vector2.ZERO, delta * 12.0)
		rotation = lerp(rotation, 0.0, delta * 12.0)


## Genera el desplazamiento pseudoaleatorio continuo utilizando ruido unidimensional.
func _shake(delta: float) -> void:
	var amount: float = pow(trauma, trauma_power)
	noise_i += delta * noise_speed

	rotation = max_roll * amount * noise.get_noise_1d(noise_i)
	offset.x = max_offset.x * amount * noise.get_noise_1d(noise_i + 100.0)
	offset.y = max_offset.y * amount * noise.get_noise_1d(noise_i + 200.0)




## Fuerza el posicionamiento instantáneo de la cámara en el objetivo actual sin suavizado.
func reset_camera_to_target() -> void:
	if not player:
		player = get_tree().get_first_node_in_group("Player")

	if player:
		virtual_target = player.global_position + Vector2(0.0, vertical_offset)
		global_position = virtual_target
		current_anticipation = Vector2.ZERO
