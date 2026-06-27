extends Area2D

var camera: CustomCamera
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

	await initial_camera()
	is_ready = true


## Inicializa de forma inmediata si el jugador ya está dentro al cargar la escena
func initial_camera() -> void:
	await get_tree().physics_frame
	await get_tree().physics_frame

	if not camera: return

	for body in get_overlapping_bodies():
		if body is Player:
			camera.enable_deadzone = usar_zona_muerta
			var limits = _calcular_limites()
			camera.set_immediate_limits(limits, self)
			break


## Calcula los límites basados en el primer CollisionShape2D (Diseño predefinido)
func _calcular_limites() -> Dictionary:
	var limits = {
		"left": -10000000,
		"top": -10000000,
		"right": 10000000,
		"bottom": 10000000
	}

	var collision = get_child(0) as CollisionShape2D
	if collision and collision.shape:
		var size = collision.shape.size
		print(collision.global_position)

		var limits_left = int(collision.global_position.x - (size.x / 2.0))
		var limits_top = int(collision.global_position.y - (size.y / 2.0))

		if activate_left_limit: limits["left"] = limits_left
		if activate_top_limit: limits["top"] = limits_top
		if activate_right_limit: limits["right"] = int(limits_left + size.x)
		if activate_bottom_limit: limits["bottom"] = int(limits_top + size.y)

	return limits


func _on_body_entered(body: Node2D) -> void:
	if body is Player and is_ready and camera:
		camera.enable_deadzone = usar_zona_muerta
		camera.transition_to_limits(_calcular_limites(), tiempo_entrada, tipo_curva_entrada, self)


func _on_body_exited(body: Node2D) -> void:
	if body is Player and camera:
		camera.remove_limits_from_zone(self, tiempo_salida, tipo_curva_salida)
