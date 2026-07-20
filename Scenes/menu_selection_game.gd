extends Control

var panel:PackedScene = load("res://Scenes/game_panel.tscn")

@onready var bg: TextureRect = $AspectRatioContainer/bg
@onready var camera: Camera2D = $AspectRatioContainer/Camera2D
@onready var zoom: Button = $AspectRatioContainer/bg/Panel/zoom

var is_zoom: bool = false
var tw: Tween


func _ready() -> void:
	center_camera_on_viewport()
	get_viewport().size_changed.connect(center_camera_on_viewport)
	animated_bg()
	zoom_flicker()
	for slot:Slot in SaveManager.available_slots:
		var inst = panel.instantiate()
		inst.slot = slot
		#$Panel/container.add_child(inst)


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
	var camera_zoom: Vector2 = Vector2(6.0, 6.0) if is_zoom else Vector2.ONE

	var te: Tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_CUBIC)
	#te.tween_property($directional_light, "energy", energy_zoom, 1.8)
	te.tween_property(camera, "zoom", camera_zoom, 1.8)

	zoom.disabled = false
	zoom.mouse_filter =  Control.MOUSE_FILTER_IGNORE if is_zoom else Control.MOUSE_FILTER_STOP


func zoom_flicker() -> void:
	is_zoom = false
	if tw: tw.kill()

	tw = create_tween()
	tw.chain().tween_interval(4.0)

	tw.set_loops()
	tw.tween_method(func (i:int) -> void: if is_zoom: tw.kill(), 0, 0, 0.0)
	tw.tween_property(zoom, ^"theme_override_styles/normal:border_color", Color("b99700"), 0.5)
	tw.tween_interval(0.5)
	tw.tween_property(zoom, ^"theme_override_styles/normal:border_color", Color(0.0, 0.0, 0.0, 0.0), 0.5)
	tw.tween_interval(0.5)


func _on_back_zoom_pressed() -> void:
	zoom_flicker()
	_zoom()
