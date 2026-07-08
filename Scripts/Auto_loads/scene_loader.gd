# Scene loading
extends Node

var spawn_point_id: String
var player_direction: Vector2
var world: World


func level_change(door_id: String = "", direction: Vector2 = Vector2.ZERO) -> void:
	spawn_point_id = door_id
	player_direction = direction


## Instancia la escena del nivel especificado
## y posiciona al jugador en las coordenadas correspondientes.
func change_scene(scene_path: String) -> void:
	if not ResourceLoader.exists(scene_path):
		push_error("World Error: The level scene path does not exist: " + scene_path)
		return

	var level_resource = load(scene_path)
	var level_instance = level_resource.instantiate()

	var child = world.level_container.get_child(0)
	world.level_container.remove_child(child)
	child.queue_free()

	world.level_container.add_child(level_instance)
