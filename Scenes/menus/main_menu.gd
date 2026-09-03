extends Control

signal changen(path: String)

@onready var clous_v: Array[TextureRect] = [
	$clou1/clou_v1,
	$clou2/clou_v2,
	$clou2/clou_v3,
	$clou3/clou_v4,
	$clou3/clou_v5
]

@onready var sky0: ColorRect = $sky0
@onready var sky1: TextureRect = $sky1/sky1
@onready var sky2: TextureRect = $sky2/sky2
@onready var start: TextureRect = $starts/start
@onready var clou: TextureRect = $clou0/clou
@onready var terrain1: TextureRect = $terrain1/terrain1
@onready var terrain2: TextureRect = $terrain2/terrain2

@onready var vortex: CanvasLayer = $vortex_transition
@onready var anim: AnimationPlayer = %anim
@onready var panel_material: ShaderMaterial = %Panel.material as ShaderMaterial
@onready var main: VBoxContainer = %main
@onready var option: VBoxContainer = %options
@onready var background: NinePatchRect = %background
@onready var other_roll: Panel = %other_roll
@onready var title: Label = %title

enum Option { CONTROLS, AUDIOS , EXTRAS }

var timer: float = 0.0
var current_state: int = 0
var previous_title: String
var options: Option = Option.CONTROLS:
	set(val):
		options = val
		match val:
			Option.CONTROLS: %controls.visible = true;  %settings.visible = false; %extras.visible = false
			Option.AUDIOS: %settings.visible = true;  %extras.visible = false; %controls.visible = false
			Option.EXTRAS: %extras.visible = true;  %controls.visible = false; %settings.visible = false


func _ready() -> void:
	title.text = tr("Menu")
	_audio_ready()
	_ready_background()
	_hide_magic()
	anim.play(&"close")
	await vortex.transition_out(0.4)
	anim.play_backwards(&"close")
	await anim.animation_finished
	_show_magic()


func _process(delta: float) -> void:
	timer += delta
	if timer >= 40.0:
		if current_state != 400:
			current_state = 400
			_change_texture(400)
		timer = 0.0
		current_state = 0

	elif timer >= 30.0:
		if current_state != 300:
			current_state = 300
			_change_texture(300)

	elif timer >= 20.0:
		if current_state != 200:
			current_state = 200
			_change_texture(200)

	elif timer >= 10.0:
		if current_state != 100:
			current_state = 100
			_change_texture(100)


func save_settings() -> void:
	SaveManager.save_game_settings()


func _on_start_btn_pressed() -> void:
	await  _hide_magic()
	anim.play(&"close")
	await anim.animation_finished
	await vortex.transition_in(0.4)
	changen.emit("res://Scenes/menus/menu_selection_game.tscn")


func _on_options_btn_pressed() -> void:
	await _option_change()
	previous_title = title.text
	title.text = tr("Options")


func _on_extra_btn_pressed() -> void:
	await  _hide_magic()
	anim.play(&"close")
	await anim.animation_finished
	%other_roll/anim2.play(&"max")
	options = Option.EXTRAS


func _on_contros_pressed() -> void:
	await  _hide_magic()
	anim.play(&"close")
	await anim.animation_finished
	%other_roll/anim2.play(&"max")
	options = Option.CONTROLS


func _on_audios_pressed() -> void:
	await  _hide_magic()
	anim.play(&"close")
	await anim.animation_finished
	%other_roll/anim2.play(&"max")
	options = Option.AUDIOS


func _on_back_control_pressed() -> void:
	%other_roll/anim2.play_backwards(&"max")
	await  %other_roll/anim2.animation_finished
	anim.play_backwards(&"close")
	await anim.animation_finished
	await  _show_magic()


func _on_back_pressed() -> void:
	await _option_change(false)
	title.text = tr(previous_title)


func _option_change(is_options: bool = true) -> void:
	await _hide_magic()
	anim.play(&"close")
	await anim.animation_finished
	await Util.timerout(0.2)
	option.visible = is_options
	main.visible = !is_options
	anim.play_backwards(&"close")
	await anim.animation_finished
	_show_magic()


func _on_exit_btn_pressed() -> void:
	await  _hide_magic()
	anim.play(&"close")
	await anim.animation_finished
	await vortex.transition_in(0.4)
	get_tree().quit()


func _hide_magic(duration: float = 1.0) -> Signal:
	var tween = create_tween()
	tween.tween_property(panel_material, "shader_parameter/progress", 1.0, duration)
	return tween.finished


func _show_magic(duration: float = 1.0) -> Signal:
	var tween = create_tween()
	tween.tween_property(panel_material, "shader_parameter/progress", 0.0, duration)
	return tween.finished


func _ready_background() -> void:
	pass
#	background.expand_mode = NinePatchRect.EXPAND_IGNORE_SIZE
#	background.stretch_mode = NinePatchRect.STRETCH_SCALE
	#background.rotation_degrees = 90.0
	#get_viewport().size_changed.connect(_on_viewport_resized)
	#_actualizar_transformacion()


func _on_viewport_resized() -> void:
	_actualizar_transformacion()


func _actualizar_transformacion() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size
	background.size = Vector2(viewport_size.y, viewport_size.x)
	background.pivot_offset = background.size / 2.0
	background.position = (viewport_size / 2.0) - background.pivot_offset


func _change_texture(time: int) -> void:
	var index: int = 0
	match time:
		100: index = 1
		200: index = 2
		300: index = 3
		400: index = 4
		_: return

	var target_color: Color
	match index:
		1: target_color = Color("1d2e4b")
		2: target_color = Color("68B5DFFF")
		3: target_color = Color("68B5DFFF")
		4: target_color = Color("401E43FF")

	var tween = create_tween().set_parallel(true)
	tween.tween_property(sky0, "color", target_color, 1.0)

	var sprites = [sky1, sky2, start, clou, terrain1, terrain2]
	var texture_paths = [
		"res://Textures/Ui/main_menu/paralax%d/sky1.png" % index,
		"res://Textures/Ui/main_menu/paralax%d/sky2.png" % index,
		"res://Textures/Ui/main_menu/paralax%d/start.png" % index,
		"res://Textures/Ui/main_menu/paralax%d/clou.png" % index,
		"res://Textures/Ui/main_menu/paralax%d/terrain1.png" % index,
		"res://Textures/Ui/main_menu/paralax%d/terrain2.png" % index
	]

	clous_v[0].modulate.a = 0.2 if index == 3 else 0.070
	clous_v[1].modulate.a = 1.1 if index == 3 else 0.49
	clous_v[2].modulate.a = 1.5 if index == 3 else 0.62
	clous_v[3].modulate.a = 1.1 if index == 3 else 0.49
	clous_v[4].modulate.a = 1.5 if index == 3 else 0.62

	for i in range(sprites.size()):
		var texture = load(texture_paths[i])
		if texture: sprites[i].texture = texture
		else: sprites[i].texture = null


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
