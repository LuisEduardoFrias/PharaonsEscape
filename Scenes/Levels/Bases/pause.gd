extends Control


func _on_continuous_pressed() -> void:
	visible = false
	get_tree().paused = false


func _on_options_pressed() -> void:
	pass # Replace with function body.


func _on_save_game_pressed() -> void:
	Global.save_game()


func _on_exit_game_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/menus/menu_container.tscn")




#-------------------

@onready var settings: TextureRect = $Panel/settings

#----------------------------------
#----- AJUSTES (AUDIO E IDIOMA) ---
#----------------------------------
#region

@onready var checkbox_melody: CheckBox = %checkbox_melody
@onready var hslider_melody: HSlider = %hslider_melody
@onready var checkbox_audio: CheckBox = %checkbox_audio
@onready var hslider_audio: HSlider = %hslider_audio
@onready var languaje: OptionButton = %languaje

var bus_melody_idx: int
var bus_sfx_idx: int

# Mapeo de índices del OptionButton al código ISO de idioma
const LOCALE_MAP = {
	GameSettings.Code_Trans.EN: "en",
	GameSettings.Code_Trans.ES: "es"
}


func _audio_ready() -> void:
	bus_melody_idx = AudioServer.get_bus_index("melody")
	bus_sfx_idx = AudioServer.get_bus_index("sfx")

	_setup_slider(hslider_melody)
	_setup_slider(hslider_audio)
	_setup_language_option_button()

	# Cargar ajustes persistentes (Audio e Idioma)
	_load_audio_settings()
	_load_language_settings()

	# Conexión de señales de Audio
	hslider_melody.value_changed.connect(_on_melody_slider_changed)
	checkbox_melody.toggled.connect(_on_melody_checkbox_toggled)
	hslider_audio.value_changed.connect(_on_sfx_slider_changed)
	checkbox_audio.toggled.connect(_on_sfx_checkbox_toggled)

	# Conexión de señal de Idioma
	languaje.item_selected.connect(_on_language_selected)


func _setup_slider(slider: HSlider) -> void:
	slider.min_value = 0.0001
	slider.max_value = 1.0
	slider.step = 0.01


func _setup_language_option_button() -> void:
	languaje.clear()
	# Los IDs deben coincidir con los valores numéricos del Enum (0: EN, 1: ES)
	languaje.add_item("English", GameSettings.Code_Trans.EN)
	languaje.add_item("Español", GameSettings.Code_Trans.ES)


# --- Configuración de Audio ---

func _load_audio_settings() -> void:
	var data: Dictionary = Global.get_audio()

	if data.is_empty():
		_sync_ui_with_audio(bus_melody_idx, hslider_melody, checkbox_melody)
		_sync_ui_with_audio(bus_sfx_idx, hslider_audio, checkbox_audio)
		return

	if data.has("melody_on"):
		checkbox_melody.button_pressed = data["melody_on"]
		AudioServer.set_bus_mute(bus_melody_idx, not data["melody_on"])

	if data.has("melody_vol"):
		var linear_val: float = data["melody_vol"] / 100.0
		hslider_melody.value = linear_val
		AudioServer.set_bus_volume_db(bus_melody_idx, linear_to_db(linear_val))

	if data.has("sfx_on"):
		checkbox_audio.button_pressed = data["sfx_on"]
		AudioServer.set_bus_mute(bus_sfx_idx, not data["sfx_on"])

	if data.has("sfx_vol"):
		var linear_val: float = data["sfx_vol"] / 100.0
		hslider_audio.value = linear_val
		AudioServer.set_bus_volume_db(bus_sfx_idx, linear_to_db(linear_val))


func _save_audio_settings() -> void:
	var audio_data: Dictionary = {
		"melody_on": checkbox_melody.button_pressed,
		"melody_vol": int(hslider_melody.value * 100),
		"sfx_on": checkbox_audio.button_pressed,
		"sfx_vol": int(hslider_audio.value * 100)
	}
	Global.save_audio(audio_data)


func _sync_ui_with_audio(bus_idx: int, slider: HSlider, checkbox: CheckBox) -> void:
	if bus_idx == -1:
		push_error("¡El bus de audio no existe!")
		return

	var db_val = AudioServer.get_bus_volume_db(bus_idx)
	slider.value = db_to_linear(db_val)
	checkbox.button_pressed = not AudioServer.is_bus_mute(bus_idx)


# --- Configuración de Idioma ---

func _load_language_settings() -> void:
	var current_lang: GameSettings.Code_Trans = Global.get_language()

	# Seleccionar la opción correspondiente en el OptionButton
	var item_index: int = languaje.get_item_index(current_lang)
	if item_index != -1:
		languaje.select(item_index)

	# Aplicar el idioma globalmente
	_apply_language(current_lang)


func _apply_language(code: GameSettings.Code_Trans) -> void:
	if LOCALE_MAP.has(code):
		TranslationServer.set_locale(LOCALE_MAP[code])


# --- Eventos UI con auto-guardado ---

func _on_melody_slider_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bus_melody_idx, linear_to_db(value))
	_save_audio_settings()


func _on_melody_checkbox_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(bus_melody_idx, not toggled_on)
	_save_audio_settings()


func _on_sfx_slider_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(bus_sfx_idx, linear_to_db(value))
	_save_audio_settings()


func _on_sfx_checkbox_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(bus_sfx_idx, not toggled_on)
	_save_audio_settings()


func _on_language_selected(index: int) -> void:
	var selected_code: GameSettings.Code_Trans = languaje.get_item_id(index) as GameSettings.Code_Trans
	_apply_language(selected_code)
	Global.save_language(selected_code)

#endregion
