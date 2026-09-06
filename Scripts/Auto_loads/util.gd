extends Node2D
#class_name Util

var section: SectionBase


func _ready() -> void:
	section = owner


## retorna un signal de una espera del tiempo especificado
func timerout(time: float) -> Signal:
	return get_tree().create_timer(time).timeout


## Busca el nodo principal de UI en el grupo correspondiente.
'''func _find_ui_manager() -> Ui:
	return get_tree().get_first_node_in_group("Ui")'''


## Busca el nodo Player
func _find_player() -> Player:
	return get_tree().get_first_node_in_group("Player")


func _find_owner() -> World:
	return get_tree().get_first_node_in_group("World")


func _find_tittle() -> Control:
	return get_tree().get_first_node_in_group("tittle")


func _find_vortex() -> CanvasLayer:
	return get_tree().get_first_node_in_group("vortex")


func reset_current_camera_limits() -> void:
	var current_camera: Camera2D = get_viewport().get_camera_2d()
	if current_camera:
		current_camera.limit_left = -10000000
		current_camera.limit_top = -10000000
		current_camera.limit_right = 10000000
		current_camera.limit_bottom = 10000000


func temporarily_switch_camera(camera1: Camera2D, camera2: Camera2D, callback: Callable, _await_timein: float = 1.0, await_timeout: float = 3.0) -> void:
	await Global.current_scene.change_scene_screen.transition_out(1.0)
	camera1.enabled = false
	camera2.enabled = true
	await Global.current_scene.change_scene_screen.transition_in()
	callback.call()
	await timerout(await_timeout)
	await Global.current_scene.change_scene_screen.transition_out(1.0)
	camera2.enabled = false
	camera1.enabled = true
	await Global.current_scene.change_scene_screen.transition_in()


## Anima la región recortada de la textura de un nodo recorriendo una cuadrícula de frames.
##
## Utíl para sprite sheets con múltiples animaciones o capas.
##
## @param width Número total de columnas (frames horizontales) por fila en la cuadrícula.
## @param height Número total de filas (frames verticales) en la cuadrícula.
## @param r_w Ancho de cada frame individual en píxeles.
## @param r_h Alto de cada frame individual en píxeles.
## @param node Nodo objetivo que posee la textura a animar.
## @param count_frame Cantidad total de frames que dura la animación.
## @param offset_position Coordenada (X, Y) en píxeles donde inicia la animación dentro de la imagen.
## @param speed Duración total en segundos del ciclo de animación.
## @param is_loop Determina si la animación debe repetirse en bucle continuo.
func region_animation(
	width: int,
	_height: int,
	r_w: float,
	r_h: float,
	node: Node,
	count_frame: int,
	offset_position: Vector2 = Vector2.ZERO,
	speed: float = 3.0,
	is_loop: bool = true,
	step_loop: int = 0
) -> Tween:
	var t: Tween = create_tween()
	if is_loop:
		t.set_loops(step_loop)
	# Usamos count_frame - 1 porque los índices van de 0 a (count_frame - 1)
	t.tween_method(func (i: int) -> void:
		var x: float = i % width
		var y: int = int(i / float(width))# var y: int = int(i / float(height))

		if node and "texture" in node and node.texture:
			node.texture.region = Rect2(
				offset_position.x + (r_w * x),
				offset_position.y + (r_h * y),
				r_w,
				r_h
			)
	, 0, count_frame - 1, speed)
	return t
