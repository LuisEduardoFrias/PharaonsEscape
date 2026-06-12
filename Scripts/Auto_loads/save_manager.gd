extends Node

const BASE_FOLDER: String = "save_pharaons_escape/"

## El recurso SlotManager que mantiene el estado actual de los tres perfiles.
var slots_profile: SlotManager

var _base_path: String
var _ext: String


func _ready() -> void:
	_setup_env()
	# Precargamos los slots al iniciar el juego para tenerlos listos en memoria
	slots_profile = _load_slot_manager()


## Devuelve un array nativo con los 3 slots para leer sus metadatos desde la UI.
func get_all_slots() -> Array[Slot]:
	return [slots_profile.slot1, slots_profile.slot2, slots_profile.slot3]


## Crea una partida limpia en un slot específico (1, 2 o 3) e inicializa su archivo Data.
func create_new_slot_game(slot_index: int, difficulty: Data.DifficultyType, language: Data.Code_Trans) -> Data:
	var slot_id: String = "slot_" + str(slot_index)
	var data_path: String = _base_path + slot_id + "/game_data" + _ext

	var new_data: Data = Data.new()
	new_data.difficulty = difficulty
	new_data.languaje = language
	new_data.is_initial = true

	var new_slot: Slot = Slot.new()
	new_slot.slot_id = slot_id
	new_slot.index_ui = slot_index
	new_slot.data_game_path = data_path

	_save_game_file(new_slot, new_data)
	_update_manager_slot(slot_index, new_slot)
	_save_slot_manager()

	return new_data


## Carga y devuelve los datos puros (Data) de un slot específico (1, 2 o 3).
func load_slot_game(slot_index: int) -> Data:
	var slot_obj: Slot = _get_slot_by_index(slot_index)
	if not slot_obj or slot_obj.data_game_path.is_empty():
		push_error("SaveManager: No data found for slot index: ", slot_index)
		return null

	var loaded_data: Data = _safe_load(slot_obj.data_game_path) as Data
	if loaded_data:
		_apply_game_settings(loaded_data)
	return loaded_data


## Guarda el estado del juego actualizando tanto los datos como los metadatos del slot.
func save_slot_game(slot_index: int, updated_slot_meta: Slot, current_data: Data) -> void:
	_save_game_file(updated_slot_meta, current_data)
	_update_manager_slot(slot_index, updated_slot_meta)
	_save_slot_manager()


## Elimina física y lógicamente el slot indicado (1, 2 o 3).
func delete_slot_game(slot_index: int) -> void:
	var slot_to_remove: Slot = _get_slot_by_index(slot_index)
	_update_manager_slot(slot_index, null)
	_save_slot_manager()

	if slot_to_remove:
		var slot_dir: String = _base_path + slot_to_remove.slot_id + "/"
		_recursive_delete(slot_dir)


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


func _save_slot_manager() -> void:
	var path: String = _base_path + "slot_manager" + _ext
	_safe_save(slots_profile, path)


func _save_game_file(slot: Slot, data: Data) -> void:
	var slot_dir: String = _base_path + slot.slot_id + "/"
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
		dir.list_dir_begin()
		var file: String = dir.get_next()
		while file != "":
			dir.remove(file)
			file = dir.get_next()
		DirAccess.remove_absolute(path)


func _apply_game_settings(_data: Data) -> void:
	pass
