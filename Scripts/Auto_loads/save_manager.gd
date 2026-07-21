extends Node
## SaveManager: Autoload encargado de la persistencia de datos, perfiles y configuraciones.

const BASE_FOLDER: String = "save_debug_data/"

# ==============================================================================
# region VARIABLES DE LA API PÚBLICA
# ==============================================================================

## Array expuesto con los 3 slots listos para ser leídos directamente por la UI.
var available_slots: Array[Slot] = []

## Recurso de configuraciones globales (Ajustes de audio, idioma, etc.).
var game_settings: GameSettings

# endregion
# ==============================================================================
# region VARIABLES INTERNAS
# ==============================================================================

var slots_profile: SlotManager
var _base_path: String
var _ext: String

# endregion
# ==============================================================================
# region PROCESO PRINCIPAL (_READY)
# ==============================================================================

func _ready() -> void:
	_setup_env()
	_initialize_save_system()


## Prepara el entorno y carga los archivos iniciales en memoria.
func _initialize_save_system() -> void:
	# 1. Cargar o crear el manejador de perfiles
	slots_profile = _load_slot_manager()

	# 2. Asegurar que los 3 slots existan internamente (si están vacíos, se inicializan)
	_ensure_all_slots_exist()

	# 3. Actualizar la propiedad pública que usará tu UI
	_update_available_slots_property()

	# 4. Cargar configuraciones del juego
	game_settings = _load_game_settings()

# endregion
# ==============================================================================
# region API PÚBLICA (Funciones consumibles desde el exterior)
# ==============================================================================

## Recibe un Slot, determina si es nuevo o existente, realiza los procesos de inicialización si es necesario y retorna su 'Data'.
func select_and_load_slot(slot: Slot) -> Data:
	if slot.is_slot_empty:
		# Es un slot nuevo: Se inicializa su estructura física
		return _create_new_slot_game(slot.slot_id)
	else:
		# Slot existente: Se carga su archivo Data directamente
		return _load_slot_game(slot.slot_id)


## Guarda los datos actuales del juego (Data) y actualiza los metadatos visibles del Slot asociado.
func save_current_game(slot_meta: Slot, current_data: Data) -> void:
	# El slot ya no está vacío al guardar
	slot_meta.is_slot_empty = false

	_save_game_file(slot_meta, current_data)
	_update_manager_slot(slot_meta.slot_id, slot_meta)
	_save_slot_manager()
	_update_available_slots_property()


## Resetea lógicamente un slot (vuelve a sus valores por defecto) y borra sus archivos físicos de guardado.
func delete_slot_game(slot_index: int) -> void:
	var slot_to_remove: Slot = _get_slot_by_index(slot_index)

	if slot_to_remove:
		# Se borra la carpeta física de datos
		var slot_dir: String = _base_path + str(slot_to_remove.slot_id) + "/"
		_recursive_delete(slot_dir)

	# Se crea un slot limpio con los valores por defecto de tu clase Slot
	var fresh_slot: Slot = Slot.new()
	fresh_slot.slot_id = slot_index
	fresh_slot.is_slot_empty = true

	_update_manager_slot(slot_index, fresh_slot)
	_save_slot_manager()
	_update_available_slots_property()


## Guarda de forma persistente el recurso de configuraciones actuales del juego.
func save_game_settings() -> void:
	var path: String = _base_path + "game_settings" + _ext
	_safe_save(game_settings, path)

# endregion


# ==============================================================================
# region FUNCIONES INTERNAS (Lógica privada del sistema)
# ==============================================================================
#region

func _setup_env() -> void:
	if OS.is_debug_build():
		_base_path = "res://" + BASE_FOLDER
		_ext = ".tres"
	else:
		_base_path = "user://" + BASE_FOLDER
		_ext = ".res"

	if not DirAccess.dir_exists_absolute(_base_path):
		DirAccess.make_dir_recursive_absolute(_base_path)


func _load_slot_manager() -> SlotManager:
	var path: String = _base_path + "slot_manager" + _ext
	var res: Resource = _safe_load(path)
	return res if res is SlotManager else SlotManager.new()


func _load_game_settings() -> Resource:
	var path: String = _base_path + "game_settings" + _ext
	var res: GameSettings = _safe_load(path)
	if res:
		return res
	else:
		return GameSettings.new()


func _ensure_all_slots_exist() -> void:
	if not slots_profile.slot1: slots_profile.slot1 = Slot.new(); slots_profile.slot1.slot_id = 1
	if not slots_profile.slot2: slots_profile.slot2 = Slot.new(); slots_profile.slot2.slot_id = 2
	if not slots_profile.slot3: slots_profile.slot3 = Slot.new(); slots_profile.slot3.slot_id = 3


func _update_available_slots_property() -> void:
	available_slots = [slots_profile.slot1, slots_profile.slot2, slots_profile.slot3]


func _create_new_slot_game(slot_index: int) -> Data:
	var slot_id: String = "slot_%d" % slot_index
	var data_path: String = _base_path + slot_id + "/game_data" + _ext

	var new_data: Data = Data.new()
	new_data.is_initial = true

	var slot_obj: Slot = _get_slot_by_index(slot_index)
	#slot_obj.is_slot_empty = false
	slot_obj.data_game_path = data_path

	_save_game_file(slot_obj, new_data)
	_update_manager_slot(slot_index, slot_obj)
	_save_slot_manager()
	_update_available_slots_property()

	return new_data


func _load_slot_game(slot_index: int) -> Data:
	var slot_obj: Slot = _get_slot_by_index(slot_index)
	if not slot_obj or slot_obj.data_game_path.is_empty():
		push_error("SaveManager: No data path found for slot index: ", slot_index)
		return null

	return _safe_load(slot_obj.data_game_path) as Data


func _save_slot_manager() -> void:
	var path: String = _base_path + "slot_manager" + _ext
	_safe_save(slots_profile, path)


func _save_game_file(slot: Slot, data: Data) -> void:
	var slot_dir: String = "%sslot_%d/" % [_base_path, slot.slot_id]
	if not DirAccess.dir_exists_absolute(slot_dir):
		DirAccess.make_dir_recursive_absolute(slot_dir)
	_safe_save(data, slot.data_game_path)


func _get_slot_by_index(index: int) -> Slot:
	match index:
		1: return slots_profile.slot1
		2: return slots_profile.slot2
		3: return slots_profile.slot3
		_: return null


func _update_manager_slot(index: int, slot_obj: Slot) -> void:
	match index:
		1: slots_profile.slot1 = slot_obj
		2: slots_profile.slot2 = slot_obj
		3: slots_profile.slot3 = slot_obj
		_: push_error("SaveManager: Invalid slot index configuration.")


func _safe_save(resource: Resource, path: String) -> void:
	var backup: String = path + ".bak"
	if FileAccess.file_exists(path):
		DirAccess.copy_absolute(path, backup)

	var error: Error = ResourceSaver.save(resource, path)
	if error != OK:
		push_error("SaveManager Save Failure: ", error)
		if FileAccess.file_exists(backup):
			DirAccess.copy_absolute(backup, path)


func _safe_load(path: String) -> Resource:
	if not ResourceLoader.exists(path):
		return null
	var res: Resource = ResourceLoader.load(path)
	if res == null:
		var backup: String = path + ".bak"
		if ResourceLoader.exists(backup):
			res = ResourceLoader.load(backup)
	return res


func _recursive_delete(path: String) -> void:
	if DirAccess.dir_exists_absolute(path):
		var dir: DirAccess = DirAccess.open(path)
		if dir:
			dir.list_dir_begin()
			var file: String = dir.get_next()
			while file != "":
				if file != "." and file != "..":
					dir.remove(file)
				file = dir.get_next()
			DirAccess.remove_absolute(path)

#endregion
