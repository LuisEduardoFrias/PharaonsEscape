extends Area2D

# Variables para guardar los límites originales antes de entrar
var old_limit_left: int
var old_limit_top: int
var old_limit_right: int
var old_limit_bottom: int

var camera: Camera2D

@export var activate_left_limit: bool = true
@export var activate_top_limit: bool = true
@export var activate_right_limit: bool = true
@export var activate_bottom_limit: bool = true

@export_group("Configuracion de Zona Muerta")
@export var usar_zona_muerta: bool = true
@export var margen_horizontal: float = 0.2
@export var margen_vertical: float = 0.2


func _ready():
	camera = get_viewport().get_camera_2d()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	#owner.spawner_ready.connect(func() -> void:
	monitoring = true

	if camera:
		camera.drag_horizontal_enabled = usar_zona_muerta
		camera.drag_vertical_enabled = usar_zona_muerta
		if usar_zona_muerta:
			camera.drag_left_margin = margen_horizontal
			camera.drag_right_margin = margen_horizontal
			camera.drag_top_margin = margen_vertical
			camera.drag_bottom_margin = margen_vertical

	initial_camera()


func initial_camera() -> void:
	await get_tree().process_frame
	for body in get_overlapping_bodies():
		if body is Player:
			if camera:
				var collision: CollisionShape2D = get_child(0)
				var size = collision.shape.size
				var target_left = int(collision.global_position.x - (size.x / 2))
				var target_top = int(collision.global_position.y - (size.y / 2))
				var target_right = int(target_left + size.x)
				var target_bottom = int(target_top + size.y)

				if activate_left_limit: camera.limit_left = target_left
				if activate_top_limit: camera.limit_top = target_top
				if activate_right_limit: camera.limit_right = target_right
				if activate_bottom_limit: camera.limit_bottom = target_bottom
			break


# Guarda los límites de la cámara y adignal nuevos lkmites
func _on_body_entered(body: Node) -> void:
	if body is Player:
		if camera:
			old_limit_left = camera.limit_left
			old_limit_top = camera.limit_top
			old_limit_right = camera.limit_right
			old_limit_bottom = camera.limit_bottom

			var collision: CollisionShape2D = get_child(0)
			var size = collision.shape.size

			var target_left = int(collision.global_position.x - (size.x / 2))
			var target_top = int(collision.global_position.y - (size.y / 2))
			var target_right = int(target_left + size.x)
			var target_bottom = int(target_top + size.y)

			var tween: Tween = create_tween().set_parallel(true)
			if activate_left_limit :
				tween.tween_property(camera, "limit_left", target_left, 0.5).set_trans(Tween.TRANS_SINE)
			if activate_top_limit :
				tween.tween_property(camera, "limit_top", target_top, 0.5).set_trans(Tween.TRANS_SINE)
			if activate_right_limit:
				tween.tween_property(camera, "limit_right", target_right, 0.5).set_trans(Tween.TRANS_SINE)
			if activate_bottom_limit :
				tween.tween_property(camera, "limit_bottom", target_bottom, 0.5).set_trans(Tween.TRANS_SINE)


# Restaura los límites de la cámara
func _on_body_exited(body: Node) -> void:
	if body is Player:
		if camera:
			var tween: Tween = create_tween().set_parallel(true)
			if activate_left_limit :
				tween.tween_property(camera, "limit_left", old_limit_left, 0.5).set_trans(Tween.TRANS_SINE)
			if activate_top_limit :
				tween.tween_property(camera, "limit_top", old_limit_top, 0.5).set_trans(Tween.TRANS_SINE)
			if activate_right_limit:
				tween.tween_property(camera, "limit_right", old_limit_right, 0.5).set_trans(Tween.TRANS_SINE)
			if activate_bottom_limit :
				tween.tween_property(camera, "limit_bottom", old_limit_bottom, 0.5).set_trans(Tween.TRANS_SINE)
			camera.reset_physics_interpolation()
