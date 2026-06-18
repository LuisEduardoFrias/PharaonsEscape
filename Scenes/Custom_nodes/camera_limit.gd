extends Area2D

var camera: CustomCamera
var active_tween: Tween
var is_ready: bool = false

@export_group("Filtros de Limites")
@export var activate_left_limit: bool = true
@export var activate_top_limit: bool = true
@export var activate_right_limit: bool = true
@export var activate_bottom_limit: bool = true

@export_group("Configuracion de Zona Muerta")
@export var usar_zona_muerta: bool = true

@export_group("Tiempos de Transicion")
@export var tiempo_entrada: float = 0.8
@export var tiempo_salida: float = 0.8

@export_group("Curvas del Tween (Ajuste Avanzado)")
@export_enum("SINE", "QUINT", "CUBIC", "QUAD", "CIRC", "EXPO") var tipo_curva_entrada: int = 2
@export_enum("SINE", "QUINT", "CUBIC", "QUAD", "CIRC", "EXPO") var tipo_curva_salida: int = 3


func _ready() -> void:
	camera = get_viewport().get_camera_2d() as CustomCamera
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	monitoring = true

	if camera:
		camera.enable_deadzone = usar_zona_muerta

	await initial_camera()
	is_ready = true


## Inicializa los límites de la cámara de forma inmediata al cargar la escena si el jugador ya está dentro.
func initial_camera() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame

	for body in get_overlapping_bodies():
		if body is Player:
			var collision: CollisionShape2D = get_child(0)
			var size = collision.shape.size

			var target_left = int(collision.global_position.x - (size.x / 2.0))
			var target_top = int(collision.global_position.y - (size.y / 2.0))
			var target_right = int(target_left + size.x)
			var target_bottom = int(target_top + size.y)

			if activate_left_limit: camera.limit_left = target_left
			if activate_top_limit: camera.limit_top = target_top
			if activate_right_limit: camera.limit_right = target_right
			if activate_bottom_limit: camera.limit_bottom = target_bottom

			camera.force_update_scroll()
			break


## Guarda el estado actual y suaviza la transición hacia los nuevos límites al entrar al área.
func _on_body_entered(body: Node) -> void:
	if body is Player and is_ready:

		var collision: CollisionShape2D = get_child(0)
		var size = collision.shape.size

		var target_left = int(collision.global_position.x - (size.x / 2.0))
		var target_top = int(collision.global_position.y - (size.y / 2.0))
		var target_right = int(target_left + size.x)
		var target_bottom = int(target_top + size.y)

		if active_tween:
			active_tween.kill()
		active_tween = create_tween().set_parallel(true)

		var trans_type: Tween.TransitionType = _get_trans_type(tipo_curva_entrada)

		if activate_left_limit:
			active_tween.tween_property(camera, "limit_left", target_left, tiempo_entrada).set_trans(trans_type).set_ease(Tween.EASE_IN_OUT)
		if activate_top_limit:
			active_tween.tween_property(camera, "limit_top", target_top, tiempo_entrada).set_trans(trans_type).set_ease(Tween.EASE_IN_OUT)
		if activate_right_limit:
			active_tween.tween_property(camera, "limit_right", target_right, tiempo_entrada).set_trans(trans_type).set_ease(Tween.EASE_IN_OUT)
		if activate_bottom_limit:
			active_tween.tween_property(camera, "limit_bottom", target_bottom, tiempo_entrada).set_trans(trans_type).set_ease(Tween.EASE_IN_OUT)


## Restaura con amortiguación los límites anteriores al salir del área.
func _on_body_exited(body: Node) -> void:
	if body is Player:
		if active_tween:
			active_tween.kill()
		active_tween = create_tween().set_parallel(true)

		var restore_left = -10000000
		var restore_top =  -10000000
		var restore_right = 10000000
		var restore_bottom = 10000000

		var trans_type: Tween.TransitionType = _get_trans_type(tipo_curva_salida)

		active_tween.tween_property(camera, "limit_left", restore_left, tiempo_salida).set_trans(trans_type).set_ease(Tween.EASE_IN_OUT)
		active_tween.tween_property(camera, "limit_top", restore_top, tiempo_salida).set_trans(trans_type).set_ease(Tween.EASE_IN_OUT)
		active_tween.tween_property(camera, "limit_right", restore_right, tiempo_salida).set_trans(trans_type).set_ease(Tween.EASE_IN_OUT)
		active_tween.tween_property(camera, "limit_bottom", restore_bottom, tiempo_salida).set_trans(trans_type).set_ease(Tween.EASE_IN_OUT)


## Convierte el índice del menú desplegable en el enum nativo de transiciones de Godot.
func _get_trans_type(index: int) -> Tween.TransitionType:
	match index:
		0: return Tween.TRANS_SINE
		1: return Tween.TRANS_QUINT
		2: return Tween.TRANS_CUBIC
		3: return Tween.TRANS_QUAD
		4: return Tween.TRANS_CIRC
		5: return Tween.TRANS_EXPO
		_: return Tween.TRANS_SINE
