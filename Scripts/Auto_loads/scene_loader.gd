# SceneTr loading
extends Node

var spawn_point_id: String
var player_direction: Vector2
var saved_direction: Vector2
var saved_handle_pos: Vector2

func level_change(door_id: String = "", direction: Vector2 = Vector2.ZERO) -> void:
	spawn_point_id = door_id
	player_direction = direction


var _target_scene: String
var _loading_progress: Array = []

func load_scene_async(scene_path: String) -> void:
	_target_scene = scene_path
	if ResourceLoader.load_threaded_request(scene_path) == OK:
		set_process(true)

func _process(_delta: float) -> void:
	var status = ResourceLoader.load_threaded_get_status(_target_scene, _loading_progress)
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		set_process(false)
		var packed_scene = ResourceLoader.load_threaded_get(_target_scene)
		get_tree().change_scene_to_packed(packed_scene)
	elif status == ResourceLoader.THREAD_LOAD_FAILED or status == ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
		set_process(false)
