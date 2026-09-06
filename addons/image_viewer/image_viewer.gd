@tool
extends Panel

@onready var texture_rect: TextureRect = $TextureRect
@onready var zoom_slider: VSlider = $MarginContainer/PivotPanel

@export var image_texture: Texture2D:
	set(value):
		image_texture = value
		if is_node_ready():
			_update_texture()

@export var min_zoom: float = 0.1
@export var max_zoom: float = 10.0
@export var enable_pan_limits: bool = true

var current_zoom: float = 1.0
var touches: Dictionary = {}


func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = true

	if zoom_slider:
		zoom_slider.min_value = min_zoom
		zoom_slider.max_value = max_zoom
		zoom_slider.step = 0.05
		zoom_slider.value = 1.0
		if not zoom_slider.value_changed.is_connected(_on_slider_value_changed):
			zoom_slider.value_changed.connect(_on_slider_value_changed)

	_update_texture()


func set_image(p_texture: Texture2D) -> void:
	image_texture = p_texture
	current_zoom = 1.0
	touches.clear()

	if zoom_slider:
		zoom_slider.value = 1.0

	if texture_rect:
		texture_rect.position = Vector2.ZERO
		texture_rect.scale = Vector2.ONE

	_update_texture()


func _update_texture() -> void:
	if not texture_rect:
		return

	texture_rect.texture = image_texture
	texture_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	if image_texture:
		var img_size = image_texture.get_size()
		texture_rect.size = img_size
		texture_rect.pivot_offset = Vector2.ZERO
		texture_rect.position = (size - img_size) / 2.0
	else:
		texture_rect.size = Vector2(200, 200)
		texture_rect.pivot_offset = Vector2.ZERO


func _gui_input(event: InputEvent) -> void:
	if not visible or not image_texture:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_set_zoom(current_zoom * 1.1, event.position)
			accept_event()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_set_zoom(current_zoom / 1.1, event.position)
			accept_event()

	elif event is InputEventScreenTouch:
		if event.pressed:
			touches[event.index] = event.position
		else:
			touches.erase(event.index)

		accept_event()

	elif event is InputEventScreenDrag:
		touches[event.index] = event.position

		if touches.size() == 1:
			texture_rect.position += event.relative
			if enable_pan_limits:
				_apply_limits()
			accept_event()


func _on_slider_value_changed(new_value: float) -> void:
	var center_point = size / 2.0
	_set_zoom(new_value, center_point)


func _set_zoom(new_zoom: float, focal_point: Vector2) -> void:
	if not texture_rect:
		return

	var clamped_zoom = clamp(new_zoom, min_zoom, max_zoom)
	if clamped_zoom == current_zoom:
		return

	var zoom_ratio = clamped_zoom / current_zoom
	current_zoom = clamped_zoom

	if zoom_slider and not is_equal_approx(zoom_slider.value, current_zoom):
		zoom_slider.set_value_no_signal(current_zoom)

	texture_rect.scale = Vector2(current_zoom, current_zoom)
	texture_rect.position = focal_point + (texture_rect.position - focal_point) * zoom_ratio

	if enable_pan_limits:
		_apply_limits()


func _apply_limits() -> void:
	if not texture_rect or not image_texture:
		return

	var scaled_size = texture_rect.size * current_zoom
	var panel_size = size

	var min_pos = panel_size - scaled_size
	var max_pos = Vector2.ZERO

	if scaled_size.x < panel_size.x:
		texture_rect.position.x = (panel_size.x - scaled_size.x) / 2.0
	else:
		texture_rect.position.x = clamp(texture_rect.position.x, min_pos.x, max_pos.x)

	if scaled_size.y < panel_size.y:
		texture_rect.position.y = (panel_size.y - scaled_size.y) / 2.0
	else:
		texture_rect.position.y = clamp(texture_rect.position.y, min_pos.y, max_pos.y)
