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
