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

# Límites por defecto del motor de Godot
const DEFAULT_LIMIT_LEFT = -10000000
const DEFAULT_LIMIT_TOP = -10000000
const DEFAULT_LIMIT_RIGHT = 10000000
const DEFAULT_LIMIT_BOTTOM = 10000000

var trauma: float = 0.0
var trauma_power: int = 2
var noise: FastNoiseLite = FastNoiseLite.new()
var noise_i: float = 0.0

var virtual_target: Vector2 = Vector2.ZERO
var current_anticipation: Vector2 = Vector2.ZERO

# Sistema de gestión de zonas y límites dinámicos
var current_zone_owner: Node2D = null
var active_tween: Tween

# Límites actuales interpolados internamente
var current_limit_left: float = DEFAULT_LIMIT_LEFT
var current_limit_top: float = DEFAULT_LIMIT_TOP
var current_limit_right: float = DEFAULT_LIMIT_RIGHT
var current_limit_bottom: float = DEFAULT_LIMIT_BOTTOM

@onready var player: Node2D = get_tree().get_first_node_in_group("Player")


func _ready() -> void:
	noise.seed = randi()
	noise.frequency = 0.15
	position_smoothing_enabled = false
	_reset_engine_limits()

	if player:
		virtual_target = player.global_position + Vector2(0.0, vertical_offset)
		global_position = virtual_target


func _process(delta: float) -> void:
	_follow_target(delta)
	_handle_shake(delta)


func add_trauma(amount: float) -> void:
	trauma = min(trauma + amount, 1.0)


func set_constant_trauma(amount: float) -> void:
	trauma = clamp(amount, 0.0, 1.0)


## Configura límites inmediatos (útil para teletransportes o carga de escena)
func set_immediate_limits(limits: Dictionary, zone_owner: Node2D) -> void:
	current_zone_owner = zone_owner
	if active_tween: active_tween.kill()
	current_limit_left = limits["left"]
	current_limit_top = limits["top"]
	current_limit_right = limits["right"]
	current_limit_bottom = limits["bottom"]


## Transiciona suavemente hacia los límites de una nueva zona
func transition_to_limits(limits: Dictionary, duration: float, curve_index: int, zone_owner: Node2D) -> void:
	current_zone_owner = zone_owner
	if active_tween: active_tween.kill()

	active_tween = create_tween().set_parallel(true)
	var trans = _get_trans_type(curve_index)

	active_tween.tween_property(self, "current_limit_left", float(limits["left"]), duration).set_trans(trans).set_ease(Tween.EASE_IN_OUT)
	active_tween.tween_property(self, "current_limit_top", float(limits["top"]), duration).set_trans(trans).set_ease(Tween.EASE_IN_OUT)
	active_tween.tween_property(self, "current_limit_right", float(limits["right"]), duration).set_trans(trans).set_ease(Tween.EASE_IN_OUT)
	active_tween.tween_property(self, "current_limit_bottom", float(limits["bottom"]), duration).set_trans(trans).set_ease(Tween.EASE_IN_OUT)


## Elimina los límites de la zona actual si no se ha entrado a otra inmediatamente
func remove_limits_from_zone(zone_owner: Node2D, duration: float, curve_index: int) -> void:
	if current_zone_owner == zone_owner:
		current_zone_owner = null
		if active_tween: active_tween.kill()

		active_tween = create_tween().set_parallel(true)
		var trans = _get_trans_type(curve_index)

		active_tween.tween_property(self, "current_limit_left", float(DEFAULT_LIMIT_LEFT), duration).set_trans(trans).set_ease(Tween.EASE_IN_OUT)
		active_tween.tween_property(self, "current_limit_top", float(DEFAULT_LIMIT_TOP), duration).set_trans(trans).set_ease(Tween.EASE_IN_OUT)
		active_tween.tween_property(self, "current_limit_right", float(DEFAULT_LIMIT_RIGHT), duration).set_trans(trans).set_ease(Tween.EASE_IN_OUT)
		active_tween.tween_property(self, "current_limit_bottom", float(DEFAULT_LIMIT_BOTTOM), duration).set_trans(trans).set_ease(Tween.EASE_IN_OUT)

func _follow_target(delta: float) -> void:
	if not player:
		player = get_tree().get_first_node_in_group("Player")
		return

	var player_base_target: Vector2 = player.global_position + Vector2(0.0, vertical_offset)
	var previous_virtual_target: Vector2 = virtual_target

	# 1. Procesar Zona Muerta
	var pushed_deadzone: bool = false
	if enable_deadzone:
		var distance_to_player: float = virtual_target.distance_to(player_base_target)
		if distance_to_player > deadzone_radius:
			var overflow: Vector2 = (player_base_target - virtual_target).normalized() * (distance_to_player - deadzone_radius)
			virtual_target += overflow
			pushed_deadzone = true
	else:
		virtual_target = player_base_target
		pushed_deadzone = true

	# 2. Procesar Anticipación
	var target_anticipation: Vector2 = Vector2.ZERO
	if enable_anticipation and pushed_deadzone:
		var target_movement: Vector2 = virtual_target - previous_virtual_target
		if target_movement.length() > 0.01:
			target_anticipation = target_movement.normalized() * anticipation_distance

	current_anticipation = current_anticipation.lerp(target_anticipation, anticipation_smoothness * delta)
	var final_target_position: Vector2 = virtual_target + current_anticipation

	# 3. Smart Catch-up
	var current_speed: float = follow_speed
	if enable_catch_up:
		var total_distance: float = global_position.distance_to(final_target_position)
		if total_distance > catch_up_threshold:
			current_speed *= (total_distance / catch_up_threshold) * 1.5

	# 4. Interpolar posición base
	var next_position: Vector2 = global_position.lerp(final_target_position, current_speed * delta)

	# =========================================================================
	# CORRECCIÓN DE LÍMITES: Ajustar según el tamaño real de la pantalla
	# =========================================================================
	var viewport_size: Vector2 = get_viewport_rect().size
	var half_screen: Vector2 = (viewport_size / 2.0) * zoom

	# El límite se aplica restando/sumando la mitad de la pantalla a la posición central
	var min_x: float = current_limit_left + half_screen.x
	var min_y: float = current_limit_top + half_screen.y

	# Evitar que los límites se crucen si el área es más pequeña que la pantalla
	var max_x: float = max(min_x, current_limit_right - half_screen.x)
	var max_y: float = max(min_y, current_limit_bottom - half_screen.y)

	next_position.x = clamp(next_position.x, min_x, max_x)
	next_position.y = clamp(next_position.y, min_y, max_y)
	# =========================================================================

	global_position = next_position.round()

func _handle_shake(delta: float) -> void:
	if trauma > 0.0:
		trauma = max(trauma - decay * delta, 0.0)
		_shake(delta)
	else:
		offset = offset.lerp(Vector2.ZERO, delta * 12.0)
		rotation = lerp(rotation, 0.0, delta * 12.0)


func _shake(delta: float) -> void:
	var amount: float = pow(trauma, trauma_power)
	noise_i += delta * noise_speed

	rotation = max_roll * amount * noise.get_noise_1d(noise_i)
	offset.x = max_offset.x * amount * noise.get_noise_1d(noise_i + 100.0)
	offset.y = max_offset.y * amount * noise.get_noise_1d(noise_i + 200.0)


func reset_camera_to_target() -> void:
	if not player:
		player = get_tree().get_first_node_in_group("Player")

	if player:
		virtual_target = player.global_position + Vector2(0.0, vertical_offset)
		global_position = virtual_target
		current_anticipation = Vector2.ZERO


func _reset_engine_limits() -> void:
	limit_left = DEFAULT_LIMIT_LEFT
	limit_top = DEFAULT_LIMIT_TOP
	limit_right = DEFAULT_LIMIT_RIGHT
	limit_bottom = DEFAULT_LIMIT_BOTTOM


func _get_trans_type(index: int) -> Tween.TransitionType:
	match index:
		0: return Tween.TRANS_SINE
		1: return Tween.TRANS_QUINT
		2: return Tween.TRANS_CUBIC
		3: return Tween.TRANS_QUAD
		4: return Tween.TRANS_CIRC
		5: return Tween.TRANS_EXPO
		_: return Tween.TRANS_SINE
