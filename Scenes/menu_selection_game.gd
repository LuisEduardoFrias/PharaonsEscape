extends Control

@onready var btns: Array[TextureButton] = [
	$AspectRatioContainer/bg/Panel/HBoxContainer/VBoxContainer/option_btn,
	$AspectRatioContainer/bg/Panel/HBoxContainer/VBoxContainer/option_btn2,
	$AspectRatioContainer/bg/Panel/HBoxContainer/VBoxContainer/option_btn3
]
@onready var time: Label = %time
@onready var bugs: Label = %bugs
@onready var live: Label = %live
@onready var level: Label = %level
@onready var bg: TextureRect = $AspectRatioContainer/bg
@onready var camera: Camera2D = $AspectRatioContainer/Camera2D
@onready var zoom: Button = $AspectRatioContainer/bg/Panel/zoom
@onready var directional_light: DirectionalLight2D = $directional_light

var selected_slot: int = -1
var selected_slot_text: String = ""
var is_zoom: bool = false:
	set(val):
		is_zoom = val
		if val and tw:
			tw.loop_finished.connect(func(_i: int)->void: tw.kill())
var tw: Tween


func _ready() -> void:
	center_camera_on_viewport()
	get_viewport().size_changed.connect(center_camera_on_viewport)
	animated_bg()
	zoom_flicker()


	for slot: Slot in SaveManager.available_slots:
		if slot.is_slot_empty:
			btns[slot.slot_id - 1].text = "New Game"
		else:
			btns[slot.slot_id - 1].text = "Continue"


func animated_bg() -> void:
	var t: Tween = create_tween().set_loops()
	t.tween_method(func (i: int) -> void:
		var x = i % 4
		var y = int(i / 4.0)
		bg.texture.region = Rect2(578 * x, 322 * y, 578.0, 322.0)
	, 0, 12, 3.0)


func center_camera_on_viewport():
	var viewport_size = get_viewport_rect().size
	var centro_real = viewport_size / 2
	camera.global_position = centro_real


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_zoom_pressed() -> void:
	is_zoom = true
	_zoom()


func _zoom() -> void:
	var energy_zoom: float = 1.0 if is_zoom else 0.30
	var camera_zoom: Vector2 = Vector2(6.0, 6.0) if is_zoom else Vector2.ONE

	var te: Tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC)
	te.tween_property(directional_light, "energy", energy_zoom, 2.5)
	te.tween_property(camera, "zoom", camera_zoom, 2.5)

	zoom.disabled = false
	zoom.mouse_filter =  Control.MOUSE_FILTER_IGNORE if is_zoom else Control.MOUSE_FILTER_STOP


func zoom_flicker() -> void:
	is_zoom = false

	if tw and tw.is_running(): tw.kill()

	await Util.timerout(4.0)
	if is_zoom: return

	tw = create_tween()

	tw.chain().set_loops()
	tw.tween_property(zoom, ^"theme_override_styles/normal:border_color", Color("b99700"), 0.5)
	tw.tween_interval(0.5)
	tw.tween_property(zoom, ^"theme_override_styles/normal:border_color", Color.TRANSPARENT, 0.5)
	tw.tween_interval(0.5)



func _on_back_zoom_pressed() -> void:
	zoom_flicker()
	_zoom()


func _on_option_btn_pressed() -> void:
	load_data(0)


func _on_option_btn_2_pressed() -> void:
	load_data(1)


func _on_option_btn_3_pressed() -> void:
	load_data(2)


func load_data(id: int) -> void:
	var slot: Slot = SaveManager.available_slots[id]

	if selected_slot != id:
		btns[selected_slot].text = btns[selected_slot].text if selected_slot_text == "" else selected_slot_text
		selected_slot = id

		selected_slot_text = btns[id].text
		btns[id].text = "Wake up" if slot.is_slot_empty else "Start game"

		time.text = _format_unix_time(slot.time_gaming)
		bugs.text = str(slot.bugs)
		live.text = str(slot.current_live)
		level.text = slot.level_name
	else:
		Global.current_slot = slot
		if not slot.is_slot_empty:
			get_tree().change_scene_to_file("res://Scenes/Levels/Bases/history.tscn")
		else:
			get_tree().change_scene_to_file("res://Scenes/Levels/Bases/world.tscn")


## Formatea un valor unix a string de tiempo.
func _format_unix_time(unix_time_value: int) -> String:
	var d: Dictionary = Time.get_datetime_dict_from_unix_time(unix_time_value)
	return "%02d:%02d:%02d" % [d.hour, d.minute, d.second]
