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


func reset_current_camera_limits() -> void:
	var current_camera: Camera2D = get_viewport().get_camera_2d()
	if current_camera:
		current_camera.limit_left = -10000000
		current_camera.limit_top = -10000000
		current_camera.limit_right = 10000000
		current_camera.limit_bottom = 10000000


func temporarily_switch_camera(camera1: Camera2D, camera2: Camera2D, callback: Callable, await_timein: float = 1.0, await_timeout: float = 3.0) -> void:
	Global.current_scene.change_scene_screen.transition_out(1.0)
	await timerout(1.0)
	camera1.enabled = false
	camera2.enabled = true
	Global.current_scene.change_scene_screen.transition_in()
	await timerout(await_timein)
	callback.call()
	await timerout(await_timeout)
	Global.current_scene.change_scene_screen.transition_out(1.0)
	await timerout(1.0)
	camera2.enabled = false
	camera1.enabled = true
	Global.current_scene.change_scene_screen.transition_in()
