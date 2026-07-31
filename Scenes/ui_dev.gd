extends Control

# Configuración de rutas y carpetas a escanear
const FOLDERS_TO_SCAN: Array[String] = [
	"res://Scenes/Levels/level_1/",
	"res://Scenes/Levels/level_2/",
	"res://Scenes/Levels/level_3"
]

const TARGET_FILE_PATH: String = "res://Resources/Data_save/current_level_data.gd"
const HEADER_KEY: String = "#PLACEHOLDER_TO_REPLACE:"

# Configuración de animación y desplazamientos
const HIDDEN_OFFSET_X: float = 320.0  # Desplazamiento hacia la derecha para ocultar (390 - 70)
const TWEEN_DURATION: float = 0.3     # Duración de la animación en segundos

# Nodos
@onready var panel: Panel = $Panel
@onready var option_button: OptionButton = $Panel/HBoxContainer/OptionButton
@onready var toggle_button: Button = $Panel/HBoxContainer/Button

# Variables de estado y mapeo
var scenes_map: Dictionary = {}
var is_open: bool = false
var original_position_x: float = 0.0
var tween: Tween


func _ready() -> void:
	_load_scenes_from_folders()

	# Guardar la posición visible original del panel
	original_position_x = panel.position.x

	# Posicionar el panel oculto al iniciar (desplazado a la derecha)
	panel.position.x = original_position_x + HIDDEN_OFFSET_X
	is_open = false

	# Conectar señal del botón toggle
	if toggle_button:
		toggle_button.pressed.connect(_on_toggle_button_pressed)


# 1. Escanea las carpetas y llena el OptionButton
func _load_scenes_from_folders() -> void:
	option_button.clear()
	scenes_map.clear()

	for folder_path in FOLDERS_TO_SCAN:
		var dir = DirAccess.open(folder_path)
		if dir:
			dir.list_dir_begin()
			var file_name = dir.get_next()

			while file_name != "":
				if not dir.current_is_dir() and (file_name.ends_with(".tscn") or file_name.ends_with(".scn")):
					var full_path = folder_path.path_join(file_name)
					var clean_name = file_name.get_basename()

					scenes_map[clean_name] = full_path
					option_button.add_item(clean_name)

				file_name = dir.get_next()
			dir.list_dir_end()
		else:
			print("No se pudo abrir la carpeta: ", folder_path)


# 2. Controla la apertura, cierre y re-ejecución con el botón
func _on_toggle_button_pressed() -> void:
	if is_open:
		# Si está abierto, ejecutamos la lógica de guardar/intercambiar escena
		_apply_scene_and_reload()
	else:
		# Si está cerrado, simplemente lo abrimos/desplegamos
		_animate_panel(true)


# Anima la entrada/salida del panel con Tween
func _animate_panel(open: bool) -> void:
	is_open = open

	var target_x: float = original_position_x if open else (original_position_x + HIDDEN_OFFSET_X)

	# Matar tween anterior si existía para evitar solapamiento
	if tween and tween.is_running():
		tween.kill()

	tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(panel, "position:x", target_x, TWEEN_DURATION)

	# Opcional: Cambiar texto del botón como indicador visual
	toggle_button.text = "=>" if open else "<="


# 3. Reemplaza el path dinámicamente y reinicia el mundo
func _apply_scene_and_reload() -> void:
	if option_button.selected != -1:
		var selected_name = option_button.get_item_text(option_button.selected)
		var selected_scene_path = scenes_map.get(selected_name, "")

		if not selected_scene_path.is_empty():
			# 1. Guardar persistentemente en el archivo de disco .gd
			_update_file_content(selected_scene_path)

			# 2. Modificar la propiedad EN MEMORIA RAM del recurso activo
			# Al hacer load() Godot nos da la instancia/clase cargada en RAM y le cambiamos la ruta directo
			var level_data_script = load(TARGET_FILE_PATH)
			if level_data_script:
				# Si la variable en current_level_data.gd es una constante/propiedad, la asignamos
				level_data_script.set("CURRENT_SCENE", selected_scene_path)
				# Nota: Si tu variable en current_level_data.gd tiene otro nombre (ej: level_path), cámbialo arriba.

	# 3. Animar el cierre del panel
	_animate_panel(false)

	if tween:
		await tween.finished

	# 4. Recargar la escena padre / contenedora principal (world.tscn)
	get_tree().change_scene_to_file("res://Scenes/Levels/Bases/world.tscn")



# Función para extraer dinámicamente el path actual, reemplazarlo y actualizar el archivo
func _update_file_content(new_path: String) -> bool:
	if not FileAccess.file_exists(TARGET_FILE_PATH):
		print("El archivo objetivo no existe: ", TARGET_FILE_PATH)
		return false

	var file_read = FileAccess.open(TARGET_FILE_PATH, FileAccess.READ)
	var content = file_read.get_as_text()
	file_read.close()

	var lines = content.split("\n")
	var old_path: String = ""
	var header_line_index: int = -1

	for i in range(lines.size()):
		var line = lines[i].strip_edges()
		if line.begins_with(HEADER_KEY):
			header_line_index = i
			old_path = line.substr(HEADER_KEY.length()).strip_edges()
			break

	if header_line_index == -1 or old_path.is_empty():
		print("Error: No se encontró la etiqueta HEADER_KEY '#PLACEHOLDER_TO_REPLACE:'")
		return false

	if old_path == new_path:
		return true

	lines[header_line_index] = HEADER_KEY + new_path
	var updated_content = "\n".join(lines)
	updated_content = updated_content.replace(old_path, new_path)

	var file_write = FileAccess.open(TARGET_FILE_PATH, FileAccess.WRITE)
	if file_write:
		file_write.store_string(updated_content)
		file_write.close()
		return true

	return false
