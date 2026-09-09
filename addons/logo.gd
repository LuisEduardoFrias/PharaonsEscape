extends Control

@onready var control: TextureRect = $control

var _tw: Tween
var _anim_finished: bool = false

const PY: float = 100.0
const CONTROL_SIZE: Vector2 = Vector2(425.0, 275.0)
const TPY: float = 437.792
const PT_SIZE: Vector2 = Vector2(700.0, 40.0)
const STPY: float = 530.513
const PST_SIZE: Vector2 = Vector2(350.0, 40.0)


func _ready() -> void:
	control.custom_minimum_size = CONTROL_SIZE
	control.size = CONTROL_SIZE
	control.pivot_offset = CONTROL_SIZE / 2.0
	control.position = Vector2(-CONTROL_SIZE.x, PY)

	get_viewport().size_changed.connect(_on_viewport_size_changed)

	await _start_animation(control,CONTROL_SIZE, PY, 0.3)
	await _start_animation($pt ,PT_SIZE, TPY, 0.3)
	_start_animation($pst,PST_SIZE, STPY, 0.3)

	await get_tree().create_timer(0.5).timeout
	var te: Tween = Util.region_animation(4, 4, 850.0, 550.0, control, 14, Vector2.ZERO, 1.0, false)
	te.set_parallel().tween_property($title, ^"visible_characters", 10, 1.0)
	te.tween_property($sub, ^"visible_characters", 4, 0.4)


func _start_animation(node:Control, size:Vector2, py:float, time: float = 1.0) -> void:
	if _tw and _tw.is_running():
		_tw.kill()

	var target_x: float = (get_viewport_rect().size.x - size.x) / 2.0
	var target_pos: Vector2 = Vector2(target_x, py)

	_tw = create_tween()
	_tw.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tw.tween_property(node, "position", target_pos, time)
	await _tw.finished
	_anim_finished = true




func _on_viewport_size_changed() -> void:
	var ct_x: float = (get_viewport_rect().size.x - CONTROL_SIZE.x) / 2.0
	var tt_x: float = (get_viewport_rect().size.x - PT_SIZE.x) / 2.0
	var stt_x: float = (get_viewport_rect().size.x - PST_SIZE.x) / 2.0


	if _anim_finished:
		control.position.x = ct_x
		$pt.position.x = tt_x
		$pst.position.x = stt_x
	else:
		_start_animation(control, CONTROL_SIZE, PY)
		_start_animation($pt, PT_SIZE, TPY, 0.3)
		_start_animation($pst, PST_SIZE, STPY, 0.3)
