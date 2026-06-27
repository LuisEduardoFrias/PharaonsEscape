class_name EyeHorus extends Node2D

@onready var area: Area2D = $area
@onready var collision: CollisionShape2D = $area/collision
@onready var sprite: Sprite2D = $sprite

var mat: ShaderMaterial = null
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

	area.area_entered.connect(_area_entered)
	area.area_exited.connect(_area_exited)


## Sincroniza continuamente los datos del radio y la posición con el ShaderMaterial si el mapa es válido.
func _process(_delta: float) -> void:
	if mat:
		mat.set_shader_parameter("player_global_position", area.global_position)
		if collision.shape is CircleShape2D:
			mat.set_shader_parameter("skill_radius", collision.shape.radius + (25.0 if is_eye_horus_enable else 0.1))


## Almacena de forma persistente la referencia del TileMapLayer al entrar en contacto.
func _body_entered(body: Node2D) -> void:
	if body is TileMapLayer and body.material is ShaderMaterial:
		mat = body.material


## Limpia las referencias del shader y del nodo cuando se sale por completo del mapa.
func _body_exited(body: Node2D) -> void:
	if body is TileMapLayer:
		_reset_shader_params()
		mat = null


## Almacena de forma persistente la referencia del TileMapLayer al entrar en contacto.
func _area_entered(_area: Area2D) -> void:
	for child: Node2D in _area.get_children():
		if child.material and child.material is ShaderMaterial:
			if not _area.monitoring:
				_area.set_deferred("monitoring", true)
			mat = child.material
			break


## Limpia las referencias del shader y del nodo cuando se sale por completo del mapa.
func _area_exited(_area: Area2D) -> void:
		_reset_shader_params()
		if _area.monitoring:
			_area.set_deferred("monitoring", false)
		mat = null


## Controla la animación del radio previniendo que baje a cero absoluto, y fuerza una validación de colisiones.
func _enable_eje_horus() -> void:
	player.is_eye_horus_enable = !player.is_eye_horus_enable
	is_eye_horus_enable = player.is_eye_horus_enable

	# Si por algún motivo el mapa se perdió por el bug de físicas, lo recuperamos manualmente aquí
	if mat == null:
		_check_overlapping_layers()

	var tw: Tween = create_tween()
	tw.tween_property(sprite, "texture:fill_to", Vector2(1.0, 0.0) if player.is_eye_horus_enable else Vector2(0.5, 0.49), 2.0)

	# Usamos 0.1 en lugar de 0.0 para que Godot no destruya el estado de la colisión
	tw.parallel().tween_property(collision, "shape:radius", 135.0 if player.is_eye_horus_enable else 0.1, 2.0)


## Busca manualmente si el área ya se encuentra superpuesta sobre algún TileMapLayer para restaurar la referencia rota.
func _check_overlapping_layers() -> void:
	var bodies: Array[Node2D] = area.get_overlapping_bodies()
	var areas: Array[Area2D] = area.get_overlapping_areas()

	for node in bodies:
		if node.material and node.material is ShaderMaterial:
			mat = node.material
			break

	for node in areas:
		_area_entered(node)


## Limpia por completo el radio en el shader a cero absoluto para ocultar imperfecciones visuales.
func _reset_shader_params() -> void:
	if mat:
		mat.set_shader_parameter("skill_radius", 0.0)
