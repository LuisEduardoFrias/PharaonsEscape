'''class_name EyeHorus extends Node2D

@onready var area: Area2D = $area
@onready var collision: CollisionShape2D = $area/collision
@onready var sprite: Sprite2D = $sprite


var tml: TileMapLayer = null
var player: Player = null
var is_eye_horus_enable: bool = false:
	set(val):
		is_eye_horus_enable = val
		set_process(val)


func _ready() -> void:
	set_process(false)
	player = get_parent()
	area.body_entered.connect(_body_entered)
	area.body_exited.connect(_body_exited)


func _process(_delta: float) -> void:
	if tml and tml.material is ShaderMaterial:
		var mat = tml.material as ShaderMaterial

		mat.set_shader_parameter("player_global_position", area.global_position)

		if collision.shape is CircleShape2D:
			var current_radius = collision.shape.radius
			mat.set_shader_parameter("skill_radius", current_radius)


func _body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		tml = body
		is_eye_horus_enable = true


func _body_exited(body: Node2D) -> void:
	if body is TileMapLayer:
		tml = null
		is_eye_horus_enable = false


func _enable_eje_horus() -> void:
	player.is_eye_horus_enable = !player.is_eye_horus_enable

	var tw: Tween = create_tween()

	tw.tween_property(sprite, "texture:fill_to", \
	Vector2(1.0, 0.0) if player.is_eye_horus_enable else Vector2(0.5, 0.49), 2.0)

	tw.parallel().tween_property(collision, "shape:radius", \
	135.0 if player.is_eye_horus_enable else 0.01, 2.0)
'''
class_name EyeHorus extends Node2D

@onready var area: Area2D = $area
@onready var collision: CollisionShape2D = $area/collision
@onready var sprite: Sprite2D = $sprite

var tml: TileMapLayer = null
var player: Player = null
var is_eye_horus_enable: bool = false:
	set(val):
		is_eye_horus_enable = val

## Configura el estado inicial, activa el proceso y conecta las señales.
func _ready() -> void:
	set_process(true)
	player = get_parent()
	area.body_entered.connect(_body_entered)
	area.body_exited.connect(_body_exited)

## Sincroniza continuamente los datos del radio y la posición con el ShaderMaterial si el mapa es válido.
func _process(_delta: float) -> void:
	if tml and tml.material is ShaderMaterial:
		var mat = tml.material as ShaderMaterial
		mat.set_shader_parameter("player_global_position", area.global_position)
		if collision.shape is CircleShape2D:
			mat.set_shader_parameter("skill_radius", collision.shape.radius + (25.0 if is_eye_horus_enable else 0.1))

## Almacena de forma persistente la referencia del TileMapLayer al entrar en contacto.
func _body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		tml = body

## Limpia las referencias del shader y del nodo cuando se sale por completo del mapa.
func _body_exited(body: Node2D) -> void:
	if body is TileMapLayer:
		_reset_shader_params()
		tml = null

## Controla la animación del radio previniendo que baje a cero absoluto, y fuerza una validación de colisiones.
func _enable_eje_horus() -> void:
	player.is_eye_horus_enable = !player.is_eye_horus_enable
	is_eye_horus_enable = player.is_eye_horus_enable

	# Si por algún motivo el mapa se perdió por el bug de físicas, lo recuperamos manualmente aquí
	if tml == null:
		_check_overlapping_layers()

	var tw: Tween = create_tween()
	tw.tween_property(sprite, "texture:fill_to", Vector2(1.0, 0.0) if player.is_eye_horus_enable else Vector2(0.5, 0.49), 2.0)

	# Usamos 0.1 en lugar de 0.0 para que Godot no destruya el estado de la colisión
	tw.parallel().tween_property(collision, "shape:radius", 135.0 if player.is_eye_horus_enable else 0.1, 2.0)

## Busca manualmente si el área ya se encuentra superpuesta sobre algún TileMapLayer para restaurar la referencia rota.
func _check_overlapping_layers() -> void:
	var bodies = area.get_overlapping_bodies()
	for body in bodies:
		if body is TileMapLayer:
			tml = body
			break

## Limpia por completo el radio en el shader a cero absoluto para ocultar imperfecciones visuales.
func _reset_shader_params() -> void:
	if tml and tml.material is ShaderMaterial:
		var mat = tml.material as ShaderMaterial
		mat.set_shader_parameter("skill_radius", 0.0)
