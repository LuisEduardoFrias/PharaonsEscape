extends Control

@onready var btns: Array[TextureButton] = [
	$AspectRatioContainer/bg/Panel/HBoxContainer/VBoxContainer/option_btn,
	$AspectRatioContainer/bg/Panel/HBoxContainer/VBoxContainer/option_btn2,
	$AspectRatioContainer/bg/Panel/HBoxContainer/VBoxContainer/option_btn3
]
@onready var vortex: CanvasLayer = $vortex_transition
@onready var time: Label = %time
@onready var bugs: Label = %bugs
@onready var live: Label = %live
@onready var level: Label = %level
@onready var back: TextureButton = $back
@onready var accept_delete_slot: TextureButton = $AspectRatioContainer/bg/Panel/verify_panel/TextureRect/HBoxContainer/accept_delete_slot
@onready var cancel_delete_slot: TextureButton = $AspectRatioContainer/bg/Panel/verify_panel/TextureRect/HBoxContainer/cancel_delete_slot
@onready var back_zoom: TextureButton = $AspectRatioContainer/bg/Panel/HBoxContainer/TextureRect2/MarginContainer/container/Panel/MarginContainer/HBoxContainer/back_zoom
@onready var delete_slot: TextureButton = $AspectRatioContainer/bg/Panel/HBoxContainer/TextureRect2/MarginContainer/container/Panel/MarginContainer/HBoxContainer/delete_slot
@onready var bg: TextureRect = $AspectRatioContainer/bg
@onready var camera: Camera2D = $AspectRatioContainer/Camera2D
@onready var zoom: Button = $AspectRatioContainer/bg/Panel/zoom
@onready var directional_light: DirectionalLight2D = $directional_light
@onready var canvas: CanvasModulate = $CanvasModulate
@onready var anim_verify: AnimationPlayer = $AspectRatioContainer/bg/Panel/verify_panel/ani_verify

var selected_slot: int = -1:
	set(val):
		selected_slot = val
		delete_slot.disabled = true if val == -1 else SaveManager.available_slots[val].is_slot_empty
var selected_slot_text: String = ""
var is_zoom: bool = false
var tw: Tween


func _ready() -> void:
	await vortex.transition_out(0.4)
	center_camera_on_viewport()
	get_viewport().size_changed.connect(center_camera_on_viewport)
	animated_bg()
	zoom_flicker()
	show_inicial_btn_text()
	zoom.grab_focus()


func animated_bg() -> void:
	Util.region_animation(4, 4, 578.0, 322.0, bg, 12, 3.0)


func center_camera_on_viewport():
	var viewport_size = get_viewport_rect().size
	var centro_real = viewport_size / 2
	camera.global_position = centro_real


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_zoom_pressed() -> void:
	is_zoom = true
	selected_slot = -1
	load_data(0)
	_zoom()


func _zoom() -> void:
	var color_zoom: Color = Color("white") if is_zoom else Color("5d5d5d")
	var camera_zoom: Vector2 = Vector2(6.0, 6.0) if is_zoom else Vector2.ONE

	var te: Tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC)
	te.tween_property(canvas, ^"color", color_zoom, 2.5)
	te.tween_property(camera, ^"zoom", camera_zoom, 2.5)

	zoom.disabled = true
	back.disabled = true
	zoom.mouse_filter =  Control.MOUSE_FILTER_IGNORE if is_zoom else Control.MOUSE_FILTER_STOP

	btns[0].grab_focus()


func zoom_flicker() -> void:
	if tw and tw.is_running():
		tw.kill()

	is_zoom = false

	await Util.timerout(4.0)
	if is_zoom: return

	tw = create_tween()
	tw.loop_finished.connect(func (_i: int) -> void:
		if is_zoom:
			tw.kill()
	)

	tw.chain().set_loops()
	tw.tween_property(zoom, ^"theme_override_styles/normal:border_color", Color("b99700"), 0.5)
	tw.tween_interval(0.5)
	tw.tween_property(zoom, ^"theme_override_styles/normal:border_color", Color.TRANSPARENT, 0.5)
	tw.tween_interval(0.5)



func _on_back_zoom_pressed() -> void:
	clear_selected_slot()
	zoom_flicker()
	_zoom()
	selected_slot = 0
	zoom.disabled = false
	back.disabled = false
	zoom.grab_focus()


func _on_option_btn_pressed() -> void:
	load_data(0)


func _on_option_btn_2_pressed() -> void:
	load_data(1)


func _on_option_btn_3_pressed() -> void:
	load_data(2)


func _on_option_btn_focus_entered() -> void:
	pass#load_data(0)


func _on_option_btn_2_focus_entered() -> void:
	pass#load_data(1)


func _on_option_btn_3_focus_entered() -> void:
	pass#load_data(2)


func load_data(id: int) -> void:
	var slot: Slot = SaveManager.available_slots[id]

	if selected_slot != id:
		btns[selected_slot].text = btns[selected_slot].text if selected_slot_text == "" else selected_slot_text
		selected_slot = id

		selected_slot_text = btns[id].text
		btns[id].text = "Start game" if slot.is_slot_empty else "Wake up"

		time.text = _format_unix_time(slot.time_gaming)
		bugs.text = str(slot.bugs)
		live.text = str(slot.current_live)
		level.text = slot.level_name
	else:
		Global.current_slot = slot
		await vortex.transition_in(0.4)
		if slot.is_slot_empty:
			get_tree().change_scene_to_file("res://Scenes/Levels/Bases/history.tscn")
		else:
			get_tree().change_scene_to_file("res://Scenes/Levels/Bases/world.tscn")


## Formatea un valor unix a string de tiempo.
func _format_unix_time(unix_time_value: int) -> String:
	var d: Dictionary = Time.get_datetime_dict_from_unix_time(unix_time_value)
	return "%02d:%02d:%02d" % [d.hour, d.minute, d.second]


func _on_delete_pressed() -> void:
	anim_verify.play(&"play")
	cancel_delete_slot.grab_focus()
	disabled_btn(true)


func _on_cancel_delete_slot_pressed() -> void:
	anim_verify.play_backwards(&"play")
	btns[selected_slot].grab_focus()
	disabled_btn(false)


func _on_accept_delete_slot_pressed() -> void:
	var _slot: Slot = SaveManager.available_slots[selected_slot]
	SaveManager.delete_slot_game(_slot.slot_id)
	btns[0].grab_focus()
	clear_selected_slot()
	#clear_data_ui()
	load_data(0)
	show_inicial_btn_text()

	anim_verify.play_backwards(&"play")
	disabled_btn(false)


func disabled_btn(is_disabled: bool) -> void:
	for btn in btns:
		btn.disabled = is_disabled
	back_zoom.disabled = is_disabled
	delete_slot.disabled = is_disabled


func clear_selected_slot() -> void:
	selected_slot = -1
	selected_slot_text = ""


func clear_data_ui() -> void:
	time.text = _format_unix_time(0)
	bugs.text = "0"
	live.text = "6"
	level.text = CurrentLevelData.titles_to_str(CurrentLevelData.Titles.The_Grand_Gallery)


func show_inicial_btn_text() -> void:
	for slot: Slot in SaveManager.available_slots:
		btns[slot.slot_id - 1].text = "New Game" if slot.is_slot_empty else "Continue"
