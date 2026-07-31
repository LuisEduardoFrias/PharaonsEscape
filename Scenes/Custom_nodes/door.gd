@tool
class_name Door extends Area2D

## Trigger invisible para cambiar de escena.
## Coloca este nodo en el lugar donde quieras que ocurra el cambio.
## Asegúrate de que el objeto que lo cruza esté en el grupo "Player".

@export_file("*.tscn") var next_scene: String = "":
	set(val):
		if Engine.is_editor_hint() and val == "":
			printerr("[Custom Error]: El SceneTrigger: "+ name + ", no tiene una escena de destino asignada.")
		next_scene = val

@export var base_datos_claves: ChangeSceneData:
	set(val):
		base_datos_claves = val
		notify_property_list_changed()

@export_enum("UP", "DOWN", "RIGHT", "LEFT") var direction: String = "RIGHT"

const vectors = {
	"UP": Vector2.UP,
	"DOWN": Vector2.DOWN,
	"RIGHT": Vector2.RIGHT,
	"LEFT": Vector2.LEFT
}

var name_id: String = "scene-triguer"
var enabled: bool = false


func _ready() -> void:
	if not Engine.is_editor_hint():
		body_entered.connect(_on_body_entered)
		body_exited.connect(_on_body_exited)

		if not owner.is_node_ready(): await owner.ready
		if SceneLoader.spawn_point_id == name_id: spawn_player()
		else: enabled = true


#region propiedad customizada

func _get(property: StringName) -> Variant:
	if property == &"name_id":
		return name_id
	return null


func _set(property: StringName, value: Variant) -> bool:
	if property == &"name_id":
		name_id = value
		return true
	return false


func _get_property_list() -> Array[Dictionary]:
	var propiedades: Array[Dictionary] = []

	if Engine.is_editor_hint():
		var opciones = _obtener_claves_del_recurso()

		propiedades.append({
			"name": "name_id",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": opciones,
			"usage": PROPERTY_USAGE_DEFAULT
		})
	return propiedades


func _obtener_claves_del_recurso() -> String:
	if not base_datos_claves or base_datos_claves.lista_claves.is_empty():
		return "scene-triguer"

	var claves = base_datos_claves.lista_claves.keys()
	return ",".join(claves)

#endregion


func _on_body_entered(body: Node2D) -> void:
	if body is Player and next_scene != "" and enabled:
		enabled = false

		SceneLoader.level_change(name_id, vectors[direction])

		owner.change_scene_screen.transition_out()

		await get_tree().physics_frame
		await get_tree().physics_frame

		await body._move_to(vectors[direction], 0.5)

		SceneLoader.change_scene(next_scene)


func spawn_player() -> void:
	var player: Player = owner.player
	player.global_position = global_position

	var camera := get_viewport().get_camera_2d() as CustomCamera
	if camera:
		camera.reset_camera_to_target()

	var saved_direction: Vector2 = SceneLoader.player_direction
	SceneLoader.level_change()

	await get_tree().physics_frame
	await get_tree().physics_frame

	owner.change_scene_screen.transition_in()

	await get_tree().physics_frame
	await get_tree().physics_frame

	await player._move_to(saved_direction, 0.5)
	player._input_physics_off(false)

	owner.is_spawner_ready = true


func _on_body_exited(body: Node2D) -> void:
	if body is Player: enabled = true
	#print("door enabled: ", enabled)
