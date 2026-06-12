extends Node2D
class_name LevelBase

## Ruta de la carpeta donde se almacenan las escenas de las secciones del juego.
const SECTIONS_FOLDER_PATH: String = "res://sections/"

## El contenedor donde se instanciarán visualmente las escenas de cada sección.
@onready var sections_container: Node2D = $SectionsContainer

## El identificador de la sección donde el jugador se encuentra físicamente parado ahora mismo.
var current_section: String = ""

## Diccionario que almacena las instancias de las secciones activas en memoria RAM.
## Clave: Nombre de la sección (String) -> Valor: Instancia del nodo (Node2D).
var loaded_sections: Dictionary = {}


## Método de inicialización invocado por la escena World al cargar el nivel.
func initialize_level() -> void:
	current_section = Global.data.current_section

	_load_and_instance_section(current_section)
	_connect_level_portals()


## Conecta dinámicamente todos los portales existentes en la escena para escuchar sus señales.
func _connect_level_portals() -> void:
	for portal in get_tree().get_nodes_in_group("Portals"):
		if portal is SectionPortal:
			if not portal.player_entered_portal.is_connected(_on_portal_activated):
				portal.player_entered_portal.connect(_on_portal_activated)


## Carga desde el disco e instancia una sección en el contenedor si no existe en memoria.
func _load_and_instance_section(section_name: String) -> void:
	if loaded_sections.has(section_name):
		return

	var section_path: String = SECTIONS_FOLDER_PATH + section_name + ".tscn"

	if not ResourceLoader.exists(section_path):
		push_error("Level Error: Section file not found at " + section_path)
		return

	var section_resource = load(section_path)
	var section_instance = section_resource.instantiate()

	sections_container.add_child(section_instance)
	loaded_sections[section_name] = section_instance


## Libera de la memoria RAM una sección que ya no es necesaria.
func _unload_section(section_name: String) -> void:
	if loaded_sections.has(section_name):
		var section_node = loaded_sections[section_name]
		section_node.queue_free()
		loaded_sections.erase(section_name)


## Callback que se ejecuta cuando el jugador entra físicamente en cualquier portal del nivel.
func _on_portal_activated(destination_section: String) -> void:
	if destination_section == current_section:
		return

	if loaded_sections.has(destination_section):
		var previous_section: String = current_section
		current_section = destination_section
		Global.data.current_section = current_section

		_unload_section(previous_section)
	else:
		_load_and_instance_section(destination_section)
