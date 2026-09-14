extends Control

@onready var panel: Control = $Panel
@onready var control: TextureRect = $Panel/control
@onready var pt: Control = $Panel/pt
@onready var pst: Control = $Panel/pst
@onready var title: Label = $Panel/title
@onready var sub: Label = $Panel/sub
@onready var godot: TextureRect = $godot
@onready var fade: FadeInOut = $fade_in_out

@export_file("*.tscn") var scene: String

var _control_anim_done: bool = false
var _pt_anim_done: bool = false
var _pst_anim_done: bool = false

const PY: float = 100.0
const CONTROL_SIZE: Vector2 = Vector2(425.0, 275.0)
const TPY: float = 437.792
const PT_SIZE: Vector2 = Vector2(700.0, 40.0)
const STPY: float = 530.513
const PST_SIZE: Vector2 = Vector2(350.0, 40.0)


func _ready() -> void:
	fade.fade_in(0.0)

	panel.anchor_right = 1.0
	panel.anchor_bottom = 1.0

	_setup_node(control, CONTROL_SIZE)
	_setup_node(pt, PT_SIZE)
	_setup_node(pst, PST_SIZE)

	_hide_offscreen(control, CONTROL_SIZE.x, PY)
	_hide_offscreen(pt, PT_SIZE.x, TPY)
	_hide_offscreen(pst, PST_SIZE.x, STPY)

	get_viewport().size_changed.connect(_on_viewport_size_changed)

	await Util.timerout(1.0)


	await _animate_from_left(control, CONTROL_SIZE.x, PY, 0.5)
	_control_anim_done = true
	await intermittence()

	await _animate_from_left(pt, PT_SIZE.x, TPY, 0.3)
	_pt_anim_done = true

	await _animate_from_left(pst, PST_SIZE.x, STPY, 0.3)
	_pst_anim_done = true

	await get_tree().create_timer(0.5).timeout

	var te: Tween = Util.region_animation(4, 4, 850.0, 550.0, control, 14, Vector2.ZERO, 1.0, false)
	te.set_parallel().tween_property(title, ^"visible_characters", 10, 1.0)
	te.tween_property(sub, ^"visible_characters", 4, 0.4).set_delay(0.2)
	await te.finished

	await intermittence()
	await get_tree().create_timer(0.2).timeout

	fade.change_scene(_play_godot_sequence)


func _setup_node(node: Control, size: Vector2) -> void:
	node.custom_minimum_size = size
	node.size = size
	node.pivot_offset = Vector2.ZERO


func _get_centered_x(width: float) -> float:
	return (get_viewport_rect().size.x - width) / 2.0


func _animate_from_left(node: Control, width: float, py: float, time: float) -> Tween:
	_hide_offscreen(node, width, py)

	var target_x: float = _get_centered_x(width)
	var target_pos: Vector2 = Vector2(target_x, py)

	var tw: Tween = create_tween()
	tw.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tw.tween_property(node, "position", target_pos, time)
	return tw


func _hide_offscreen(node: Control, width: float, py: float) -> void:
	node.position = Vector2(-width - 500.0, py)


func _on_viewport_size_changed() -> void:
	if _control_anim_done:
		control.position.x = _get_centered_x(CONTROL_SIZE.x)
	else:
		_hide_offscreen(control, CONTROL_SIZE.x, PY)

	if _pt_anim_done:
		pt.position.x = _get_centered_x(PT_SIZE.x)
	else:
		_hide_offscreen(pt, PT_SIZE.x, TPY)

	if _pst_anim_done:
		pst.position.x = _get_centered_x(PST_SIZE.x)
	else:
		_hide_offscreen(pst, PST_SIZE.x, STPY)


func _play_godot_sequence() -> void:
	panel.visible = false

	await get_tree().create_timer(1.0).timeout

	godot.visible = true
	var te_fade: Tween = create_tween()
	te_fade.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	te_fade.tween_property(godot, ^"modulate:a", 1.0, 0.5)
	await te_fade.finished

	var te_region: Tween = Util.region_animation(3, 3, 155, 174, godot, 7, Vector2.ZERO, 1.0, false)
	await te_region.finished

	await fade.change_scene(func() -> void:godot.visible = false)
	get_tree().change_scene_to_file(scene)


func intermittence() -> Signal:
	var te: Tween = create_tween().set_loops(3)
	te.tween_property(control, ^"modulate:a", 0.0, 0.1)
	te.tween_property(control, ^"modulate:a", 1.0, 0.1)
	return te.finished
