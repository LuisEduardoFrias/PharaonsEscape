# Global
extends Node

signal added_skill(skill: SkillsData.SkillsType)
signal added_coint(value: int)
signal added_parchment(index: int)
signal added_honey(index:int)

var player_data: PlayerData #para persistir la data del Player aparte.

var current_slot: Slot:
	set(val):
		current_slot = val
		data = SaveManager.select_and_load_slot(val)
var data: Data = Data.new():
	set(val):
		data = val
		player_data = data.player
var current_scene: Node2D
var section_2_active_door: bool = false


func _ready() -> void:
	pass

# Guada los datos generales
func save() -> void:
	SaveManager.save_current_game(current_slot, data)


# Guada la partida
func save_game() -> void:
	data.player = player_data
	SaveManager.save_current_game(current_slot, data)


##Activa las puertas
func save_open_door(owner_name: LevelsData.Levels, section_name: String, door: Node2D) -> void:
	execute(owner_name, section_name, door, "doors", func (val: Variant,  prop_name: String) -> void:
		door._open()
		val[prop_name] = true
		save()
	)


##Verifica el estado de la puerta
func check_door(owner_name: LevelsData.Levels, section_name: String, door: Node2D) -> void:
	execute(owner_name, section_name, door, "doors", func (val: Variant,  prop_name: String) -> void:
		door.opening = val[prop_name]
	)


##Activa las puertas
func save_parchment(owner_name: LevelsData.Levels, section_name: String, parchment: Node2D, is_take: bool) -> void:
	execute(owner_name, section_name, parchment, "parchments", func (val: Variant, prop_name: String) -> void:
		val[prop_name] = {
			"index": parchment.index,
			"dialog_name": parchment.dialog_resouce.resource_path,
			"is_take": is_take,
			"is_interject": !is_take
		}
		parchment.anim.stop()
		parchment.dialogue_trigger.queue_free()
		added_parchment.emit(parchment.index)
		save()
	)


##Verifica el estado de la puerta
func check_parchment(owner_name: LevelsData.Levels, section_name: String, parchment: Node2D) -> void:
	execute(owner_name, section_name, parchment, "parchments", func (val: Variant, prop_name: String) -> void:
		if(val[prop_name].is_take or val[prop_name].is_interject):
			parchment.anim.stop()
			parchment.dialogue_trigger.queue_free()
	)



##Activa las puertas
func save_switch(owner_name: LevelsData.Levels, section_name: String, switch: Node2D) -> void:
	execute(owner_name, section_name, switch, "switches", func (val: Variant,  prop_name: String) -> void:
		switch._interact({})
		val[prop_name] = switch.is_active
		save()
	)


##Verifica el estado de la puerta
func check_switch(owner_name: LevelsData.Levels, section_name: String, switch: Node2D) -> void:
	execute(owner_name, section_name, switch, "switches", func (val: Variant,  prop_name: String) -> void:
		switch.is_active = val[prop_name]
	)


## Interactúa con los objetos pertenecientes a una sección específica del nivel.
##
## Busca y activa la lógica de interacción para el nodo [param objects]
## correspondiente al [param section_name] dentro de [param owner_name].
##
## - [param owner_name]: El identificador del nivel (Enum [member LevelsData.Levels]).
## - [param section_name]: El nombre de la sección a procesar.
## - [param objects]: El nodo contenedor ([Node2D]) que posee los objetos interactivos.
func interact_objects(owner_name: LevelsData.Levels, section_name: String, objects: Node2D, is_save: bool = false) -> void:
	execute(owner_name, section_name, objects, "objects", func (val: Variant,  prop_name: String) -> void:
		if val[prop_name]:
			objects._interact({})
		if is_save:
			val[prop_name] = true
			save()
	)


func execute(owner_name: LevelsData.Levels, section_name: String, node: Node2D, fill: String, callback: Callable) -> void:
	var _owner_name_: String = LevelsData.level_to_str(owner_name)
	var _node_name: String = "%s_%s" %[section_name, node.name]

	if data.levels[_owner_name_][fill] and data.levels[_owner_name_][fill].has(_node_name):
		callback.call(data.levels[_owner_name_][fill], _node_name)
	else:
		push_warning("\n[Custom Warnning]:\nLa propiedad \"", _node_name ,"\" no se encuentra en el espacio de datos globales.")


func skill_to_str(skill: SkillsData.SkillsType) -> String:
	return (SkillsData.SkillsType.keys()[skill]as String).to_lower()


func add_skill(skill: SkillsData.SkillsType) -> void:
	var skill_name : String = skill_to_str(skill)

	if data.skills[skill_name] == null:
		push_error("La habilidad '%s' no se encuentras" % skill)
		return

	data.skills.set(skill_name, true)
	equipped_skill(skill_name)
	save()
	added_skill.emit(skill_name)


#equipa la habilidad con el nombre dado en el ID del campo dado
func equipped_skill(skill_name: String) -> void:
	var skill: SkillsData.SkillsType =  skill_to_enum(skill_name)
	data.player.equipped_skills[SkillsData.equipped_index_to_skill(skill)] = skill
	save()


func skill_to_enum(skill: String) -> SkillsData.SkillsType:
	return SkillsData.SkillsType[skill.to_upper()]


func add_item(item: ItemsData.ItemType, index: int = -1) -> void:
	match item:
		ItemsData.ItemType.HONEY:
			if index == -1: push_error("Proporciona un index"); return
			data.items.honey[index] = true
			added_honey.emit(index)
		ItemsData.ItemType.PARCHMENTS:
			data.items.parchment = true
			added_parchment.emit(0)
		ItemsData.ItemType.COIN:
			data.items[ItemsData.item_to_str(item)] = true
			added_coint.emit(50)
		ItemsData.ItemType.COUNTER_COIN:
			if index == -1: push_error("Proporciona un index"); return
			data.items[ItemsData.item_to_str(item)] += index
			added_coint.emit(index)
		_: data.items[ItemsData.item_to_str(item)] = true
	save()


func hidden_item(item: ItemsData.ItemType, index: int = -1) -> bool:
	match item:
		ItemsData.ItemType.HONEY:
			if index == -1: push_error("Proporciona un index")
			return data.items.honey[index]
		ItemsData.ItemType.PARCHMENTS:
			return data.items.parchment

	return data.items[ItemsData.item_to_str(item)]


func hidden_skill(skill: SkillsData.SkillsType) -> bool:
	var skill_name : String = skill_to_str(skill)
	return data.skills[skill_name]


#region
'''
func code_trans_to_str(code_trans: Data.Code_Trans) -> String:
	return (Data.Code_Trans.keys()[code_trans] as String).to_lower()





##Verifica el estado de la puerta
func check_door(_owner_name:  LevelsData.Levels, _door_name: String) -> Variant:
	var owner_name_: String =  LevelsData.level_to_str(_owner_name)

	if data.levels[owner_name_].doors.has(_door_name):
		return data.levels[owner_name_].doors[_door_name]
	else:
		push_warning("\nCustom Warnning:\nLa propiedad \"", _door_name ,"\" no se encuentra en el espacio de datos globales.")
		return null




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
	if not ui:
		ui = get_tree().get_first_node_in_group("ui")
	ui.show_title(title)


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
	meta_data_change_escene = {
		"door_id": link_scene_id,
		"is_dark_zone": is_dark_zone
	}




func load_game(_slot: int) -> void:
	specify_slot = slot

	if data.is_initial :
		data.is_initial = false
		SaveManager.save_specify_slot_data(slot)
		get_tree().change_scene_to_file("res://Scenes/history.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/word.tscn")

	SaveManager.load_specify_slot_data(specify_slot)
'''

#endregion
