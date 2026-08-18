extends Control

@export_file("*.tscn") var back_escene: String
@export_file("*.tscn") var next_escene_word: String
@export_file("*.tscn") var next_escene_history: String

@onready var slots_map: Dictionary = {
	100: %slot_100,
	200: %slot_200,
	300: %slot_300
}

@onready var labels_map: Dictionary = {
	"time_gaming": %date_timer,
	"bugs": %bug,
	"current_live": %live,
	"level_name": %level_name,
}

@onready var panel_indicator: Panel = $background/MarginContainer/panel_indicator

var anims_play: Array[String] = ["idle_front", "idle_side"]
var indicator_on: bool = true
var current_manager: SlotManager
var tween_indicator: Tween
var active_id: int = -1

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("000000ff"))
	#current_manager = SaveManager.load_slot_manager()
	#$background/Anim.play("run")

	#_init_slots_signals()

	# ESTO ES LO NUEVO:
	#active_id = 100
	#verify_ui_slot()
	#indicator()

	#%slot_100.call_deferred("grab_focus")



## Configura las señales iniciales de los slots.
func _init_slots_signals() -> void:
	for id: int in slots_map.keys():
		var slot_node: TextureButton = slots_map[id]
		# El mouse ya no dispara cambios visuales
		slot_node.focus_entered.connect(_on_slot_focused.bind(id))
		slot_node.pressed.connect(_on_slot_selection_logic.bind(id))


## Controla el parpadeo visual del panel central.
func indicator() -> void:
	if not is_node_ready(): await ready
	await get_tree().create_timer(4.0).timeout

	if indicator_on:
		if tween_indicator: tween_indicator.kill()
		tween_indicator = create_tween().set_loops()
		tween_indicator.tween_method(func(val: int) -> void:
			panel_indicator.self_modulate = Color(1, 1, 1, val)
		, 0, 1, 2.0)


## Lógica para cuando se navega con el teclado o mando.
func _on_slot_focused(id: int) -> void:
	_update_ui(id)


## Gestiona la confirmacion de seleccion (Doble Clic / Doble Enter).
func _on_slot_selection_logic(id: int) -> void:
	if active_id == id:
		_on_slot_pressed(id)
	else:
		active_id = id
		verify_ui_slot()



## Actualiza el estado visual general de los botones.
func verify_ui_slot() -> void:
	for id: int in slots_map.keys():
		var slot_node: TextureButton = slots_map[id]
		var slot_data: Slot = _get_slot_from_manager(id)

		if id == active_id:
			slot_node.button_text = "It's time to \n g-g-g-game!"
		else:
			slot_node.button_text = "play continues" if slot_data != null else "New Game"


## Selecciona una animacion aleatoria para el preview del personaje.
func random_anim() -> String:
	return anims_play.pick_random()


## Actualiza los labels de informacion con los datos del slot.
func _update_ui(slot_id: int) -> void:
	%player_anim.play(random_anim())

	var slot_data: Slot = _get_slot_from_manager(slot_id)

	if %delete_slot.pressed.is_connected(_on_delete_pressed):
		%delete_slot.pressed.disconnect(_on_delete_pressed)
	%delete_slot.pressed.connect(_on_delete_pressed.bind(slot_id), CONNECT_ONE_SHOT)

	labels_map.time_gaming.text = _format_unix_time(slot_data.time_gaming) if slot_data else "00:00:00"
	labels_map.bugs.text = str(slot_data.bugs) if slot_data else "0"
	labels_map.level_name.text = str(slot_data.level_name) if slot_data else "_____"

	var health_val: int = slot_data.current_live if slot_data else 0
	labels_map.current_live.restore(health_val)


## Limpia la visualizacion de datos en la interfaz.
func clear() -> void:
	labels_map.time_gaming.text = "00:00:00"
	labels_map.bugs.text = "0"
	labels_map.level_name.text = "Dark"
	labels_map.current_live.restore(0)


## Inicia la carga o creacion de una partida.
func _on_slot_pressed(id: int) -> void:
	var slot_data: Slot = _get_slot_from_manager(id)

	var next_path: String = next_escene_word
	if slot_data == null:
		SaveManager.create_new_game(id, Global.current_difficulty, Global.current_language)
		current_manager = SaveManager.load_slot_manager()
		slot_data = _get_slot_from_manager(id)
		next_path = next_escene_history

	var game_data: Data = SaveManager.load_game(slot_data)
	if game_data:
		Global.data = game_data
		Global.current_slot = slot_data

	Global.trigger_screen_transition(func() -> void: get_tree().change_scene_to_file(next_path))


## Borra los datos de un slot especifico.
func _on_delete_pressed(id: int) -> void:
	match id:
		100: current_manager.slot1 = null
		200: current_manager.slot2 = null
		300: current_manager.slot3 = null
	clear()
	verify_ui_slot()


## Retorna el objeto Slot correspondiente del manager.
func _get_slot_from_manager(idx: int) -> Slot:
	@warning_ignore("integer_division")
	return current_manager.get("slot" + str(idx / 100))


## Formatea un valor unix a string de tiempo.
func _format_unix_time(unix_time_value: int) -> String:
	var d: Dictionary = Time.get_datetime_dict_from_unix_time(unix_time_value)
	return "%02d:%02d:%02d" % [d.hour, d.minute, d.second]


## Ejecuta la transicion de regreso al menu.
func _on_back_pressed() -> void:
	Global.trigger_screen_transition(func() -> void: get_tree().change_scene_to_file(back_escene))


## Resetea el zoom y reinicia el indicador visual.
func _on_back_zoom_pressed() -> void:
	zoom(true)
	indicator_on = true
	indicator()


## Controla la animacion de la camara y luces.
func zoom(out: bool) -> void:
	var energy_zoom: float = 0.0 if out else 1.5
	var camera_zoom: Vector2 = Vector2.ONE if out else Vector2(5.0, 5.0)

	var te: Tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC)
	te.tween_property($directional_light, "energy", energy_zoom, 1.8)
	te.tween_property($Camera2D, "zoom", camera_zoom, 1.8)

	$background/MarginContainer/zoom_btn.disabled = false
	$background/MarginContainer/zoom_btn.mouse_filter = Control.MOUSE_FILTER_STOP if out else Control.MOUSE_FILTER_IGNORE


## Activa el estado de seleccion al presionar el boton de zoom.
func _on_zoom_btn_pressed() -> void:
	if tween_indicator: tween_indicator.kill()
	indicator_on = false
	panel_indicator.self_modulate = Color(1, 1, 1, 0)

	active_id = 100
	verify_ui_slot()

	%slot_100.grab_focus()
	zoom(false)


func _on_slot_100_focus_exited() -> void:
	active_id = -1
	verify_ui_slot()
