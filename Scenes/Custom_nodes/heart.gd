extends TextureRect

var tw: Tween


func _ready() -> void:
	texture = texture.duplicate()
	_defaut_1()
	await Util.timerout(3)
	_hurt_1()
	await Util.timerout(5)
	_hurt_2()
	await Util.timerout(5)
	_restore()


func _defaut_1() -> void:
	if tw: tw.kill()

	tw = create_tween().set_loops()
	tw.tween_method(func (i: int) -> void:
		texture.region = Rect2(128.0 + (32 * i), 384.0, 32.0, 32.0)
	, 0, 4, 1.0)


func _hurt_1() -> void:
	if tw: tw.kill()
	tw = create_tween()
	tw.tween_method(func (i: int) -> void:
		var j: int = 32 if i < 5 else 64
		texture.region = Rect2(128.0 + (32 * i), 384.0 + j, 32.0, 32.0)
	, 0, 4, 1.0)
	tw.tween_callback(_defaut_2)


func _defaut_2() -> void:
	if tw: tw.kill()

	tw = create_tween().set_loops()
	tw.tween_method(func (i: int) -> void:
		texture.region = Rect2(128.0 + (32 * i), 448.0, 32.0, 32.0)
	, 0, 4, 1.0)


func _hurt_2() -> void:
	if tw: tw.kill()
	tw = create_tween()
	tw.tween_method(func (i: int) -> void:
		texture.region = Rect2(128.0 + (32 * i), 448.0, 32.0, 32.0)
	, 0, 4, 2.6)
	tw.tween_property(self, "texture:region", Rect2(128.0, 448.0, 32.0, 32.0), 0.0)
	tw.tween_property(self, "material:shader_parameter/gray_amount", 1.0, 1.0)


func _restore() -> void:
	if tw: tw.kill()
	tw = create_tween()
	tw.tween_property(self, "material:shader_parameter/gray_amount", 0.0, 1.0)
	tw.tween_callback(_defaut_1)
