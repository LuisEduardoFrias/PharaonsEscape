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


func region_animation(width: int, height: int, r_w: float, r_h: float, node: Node, count_frame: int, speed: float = 3.0, is_loop: bool = true) -> void:
	var t: Tween = create_tween()
	if is_loop: t.set_loops()
	t.tween_method(func (i: int) -> void:
		var x: float = i % width
		var y: int = int(i / float(height))
		if node: node.texture.region = Rect2(r_w * x, r_h * y, r_w, r_h)
	, 0, count_frame, speed)
