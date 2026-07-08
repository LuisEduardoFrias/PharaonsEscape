# Global
extends Node

enum Battle_State { READY, STARTING, FINISHED }
enum Honey_options { USE, ADD, PURIFY }

signal added_skill(name: String)
signal added_item(data:Data, item_type: ItemsData.ItemType)
signal update_Honey(arr:Array)
signal added_parchment()

var player: PlayerData #para persistir la data del Player aparte.

var current_slot: Slot
var data: Data
var is_initial: bool = true

#puerta del nivel 2
var current_scene: SectionBase = null
var active_door: bool = false

func _ready() -> void:
	SaveManager._setup_env()
'''
	var slots: SlotManager = SaveManager.load_slot_manager()
	var game_data: Data = SaveManager.load_game(slots.slot1)
	if game_data:
		Global.data = game_data
		Global.current_slot = slots.slot1
		Global.player = data.player'''


'''func validate_enemies(enemics: Array[BaseEnemic]) -> bool:
	for e in enemics:
		if is_instance_valid(e):
			return false
	return true'''


func code_trans_to_str(code_trans: Data.Code_Trans) -> String:
	return (Data.Code_Trans.keys()[code_trans] as String).to_lower()


func skill_to_str(skill: SkillsData.SkillsType) -> String:
	return (SkillsData.SkillsType.keys()[skill]as String).to_lower()


func skill_to_enum(skill: String) -> int:
	return SkillsData.SkillsType[skill.to_upper()]


##Verifica el estado de la puerta
func check_door(_owner_name:  LevelsData.Levels, _door_name: String) -> Variant:
	var owner_name_: String =  LevelsData.level_to_str(_owner_name)

	if data.levels[owner_name_].doors.has(_door_name):
		return data.levels[owner_name_].doors[_door_name]
	else:
		push_warning("\nCustom Warnning:\nLa propiedad \"", _door_name ,"\" no se encuentra en el espacio de datos globales.")
		return null


##Activa las puertas
func open_door(_owner_name:  LevelsData.Levels, _door_name: String) -> void:
	var owner_name_: String =  LevelsData.level_to_str(_owner_name)

	if data.levels[owner_name_].doors.has(_door_name):
		data.levels[owner_name_].doors[_door_name] = true
		save()
	else:
		push_warning("\nCustom Warnning:\nLa propiedad \"", _door_name ,"\" no se encuentra en el espacio de datos globales.")


func get_level_name(titles: CurrentLevelData.Titles) -> String:
	match titles:
		CurrentLevelData.Titles.TheDescendingPassage:
			return "The Descending Passage"
		CurrentLevelData.Titles.TheGrandGallery:
			return "The Grand Gallery"
		CurrentLevelData.Titles.TheKingsChamber:
			return "The King's Chamber"
		CurrentLevelData.Titles.TheGoldenPyramidion:
			return "The Golden Pyramidion"
		CurrentLevelData.Titles.TheDarkZone:
			return "The Dark Zone"
		_:
			return "Unknown Level"


## Realiza una transición de pantalla ejecutando una acción cuando está en negro.
## @param action: La función o método a ejecutar durante el punto ciego.
## @param duration: Tiempo de duración para cada fase del fade.
func trigger_screen_transition(action: Callable, duration: float = 1.0) -> void:
	var canvas := CanvasLayer.new()
	var rect := ColorRect.new()

	canvas.layer = 100
	add_child(canvas)

	rect.color = Color.BLACK
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.modulate.a = 0.0
	canvas.add_child(rect)

	var tween := create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(rect, "modulate:a", 1.0, duration)
	tween.tween_callback(action)
	tween.tween_interval(0.1)
	tween.tween_property(rect, "modulate:a", 0.0, duration)
	tween.tween_callback(canvas.queue_free)


func show_title(_title: CurrentLevelData.Titles) -> void:
	pass
	'''if not ui:
		ui = get_tree().get_first_node_in_group("ui")
	ui.show_title(title)'''


func add_skill(_name: SkillsData.SkillsType) -> void:
	var name_ : String = (SkillsData.SkillsType.keys()[_name] as String).to_lower()

	if data.skills[name_] == null:
		push_error("La habilidad '%s' no se encuentras" %_name)
		return

	data.skills.set(name_, true)
	save()
	added_skill.emit(name_)


func save() -> void:
	SaveManager.save_game_data(current_slot, data)


#equipa la habilidad con el nombre dado en el ID del campo dado
func add_equipped_skill(field_id: int, skill_name: String) -> void:
	@warning_ignore("int_as_enum_without_cast")
	data.player.equipped_skills[field_id] = skill_to_enum(skill_name)
	save()


func remove_item(item_type: ItemsData.ItemType) -> void:
	data.items.set(ItemsData.item_to_str(item_type), 0)
	added_item.emit(data, item_type)
	save()


func add_item(item_type: ItemsData.ItemType) -> void:
	if item_type == ItemsData.ItemType.HONEY:
		update_honey(Honey_options.ADD)
		return

	data.items.set(ItemsData.item_to_str(item_type), 1)
	added_item.emit(data, item_type)
	save()


func add_incremental_item_code(level_owner: LevelsData.Levels, item_name: String) -> void:
	(data.levels.get(LevelsData.level_to_str(level_owner)).goldens_scarabs as Array).append(item_name)
	save()


## marcar los pergaminos recogidos
func save_parchment(index_id: int) -> void:
	data.items.parchments[index_id] = true
	save()
	added_parchment.emit()


func update_honey(op: Honey_options) -> void:
	var slot_libre: int = -1
	var val: Variant = null

	match op:
		Honey_options.ADD:
			slot_libre = data.items.honey.find(null)
			val = false
		Honey_options.PURIFY:
			slot_libre = data.items.honey.find(false)
			val = true
		Honey_options.USE:
			slot_libre = data.items.honey.rfind(true)
			val = null

	if slot_libre != -1:
		data.items.honey[slot_libre] = val
	save()
	update_Honey.emit(data.items.honey)









func check_equipped_skill(skill: SkillsData.SkillsType) -> bool:
	var equipped_skills :Array =  data.player.equipped_skills
	for i :SkillsData.SkillsType in equipped_skills:
		if i == skill:
			return true
	return false


func save_meta_data_change_escene(_link_scene_id: StringName, _is_dark_zone: bool) -> void:
	pass
	'''meta_data_change_escene = {
		"door_id": link_scene_id,
		"is_dark_zone": is_dark_zone
	}'''




func load_game(_slot: int) -> void:
	pass
	'''specify_slot = slot

	if data.is_initial :
		data.is_initial = false
		SaveManager.save_specify_slot_data(slot)
		get_tree().change_scene_to_file("res://Scenes/history.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/word.tscn")

	SaveManager.load_specify_slot_data(specify_slot)'''
