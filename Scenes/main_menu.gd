extends Control

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
@onready var background: TextureRect = %background
@onready var other_roll: Panel = %other_roll
@onready var title: Label = %title

enum Option { CONTROLS, AUDIOS , EXTRAS }

var timer: float = 0
var previous_title: String
var options: Option = Option.CONTROLS:
	set(val):
		options = val
		match val:
			Option.CONTROLS: %controls.visible = true;  %audios.visible = false; %extras.visible = false
			Option.AUDIOS: %audios.visible = true;  %extras.visible = false; %controls.visible = false
			Option.EXTRAS: %extras.visible = true;  %controls.visible = false; %audios.visible = false


func _ready() -> void:
	title.text = tr("Menu")
	_ready_background()
	_hide_magic()
	anim.play(&"close")
	await vortex.transition_out(0.4)
	anim.play_backwards(&"close")
	await anim.animation_finished
	_show_magic()


func _process(delta: float) -> void:
	timer += delta
	print(timer)
	if timer >= 10.0 and timer <= 10.01:
		_change_texture(100)
	elif timer >= 20.0 and timer <= 20.01:
		_change_texture(200)
	elif timer >= 30.0:
		_change_texture(300)
		timer = 0.0


func save_settings() -> void:
	SaveManager.save_game_settings()


func _on_start_btn_pressed() -> void:
	await  _hide_magic()
	anim.play(&"close")
	await anim.animation_finished
	await vortex.transition_in(0.4)
	get_tree().change_scene_to_file("res://Scenes/menu_selection_game.tscn")


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
	background.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	background.stretch_mode = TextureRect.STRETCH_SCALE
	background.rotation_degrees = 90.0
	get_viewport().size_changed.connect(_on_viewport_resized)
	_actualizar_transformacion()


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
		_: return

	var target_color: Color
	match index:
		1: target_color = Color("407887ff")
		2: target_color = Color("66d3ffff")
		3: target_color = Color("1d2e4b")

	var tween = create_tween().set_parallel(true)
	tween.tween_property(sky0, "color", target_color, 1.0)

	var sprites = [sky1, sky2, start, clou, terrain1, terrain2]
	var texture_paths = [
		"res://Textures/Ui/ main_menu/paralax%d/sky.png" % index,
		"res://Textures/Ui/ main_menu/paralax%d/sky2.png" % index,
		"res://Textures/Ui/ main_menu/paralax%d/start.png" % index,
		"res://Textures/Ui/ main_menu/paralax%d/clou.png" % index,
		"res://Textures/Ui/ main_menu/paralax%d/terrain1.png" % index,
		"res://Textures/Ui/ main_menu/paralax%d/terrain2.png" % index
	]

	var fade_tween = create_tween()

	for sprite in sprites:
		fade_tween.parallel().tween_property(sprite, "modulate:a", 0.0, 0.5)

	fade_tween.chain().tween_callback(func():
		for i in range(sprites.size()):
			sprites[i].texture = load(texture_paths[i])
	)

	for sprite in sprites:
		fade_tween.parallel().tween_property(sprite, "modulate:a", 1.0, 0.5)
