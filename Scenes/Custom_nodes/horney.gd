extends TextureRect

var tw: Tween


func _ready() -> void:
	texture = texture.duplicate()
	_defaut_1()
	'''await Util.timerout(2)
	_defaut_2()
	await Util.timerout(3)
	_use_1()
	await Util.timerout(5)
	_use_2()
	await Util.timerout(5)
	_restore()'''


func _defaut_1() -> void:
	if tw: tw.kill()
	texture.region = Rect2(480.0, 224.0, 48.0, 48.0)
	modulate = Color("303030ff")


func _defaut_2() -> void:
	if tw: tw.kill()
	texture.region =  Rect2(480.0, 224.0, 48.0, 48.0)
	modulate = Color("ffffffff")


func _use_1() -> void:
	if tw: tw.kill()
	tw = create_tween()
	tw.tween_method(func (x: int) -> void:
		var j: int = int(x / 5.0)
		var i: int = x % 5
		texture.region = Rect2(480.0 + (48 * i), 224.0 + (48 * j), 48.0, 48.0)
	, 0, 7, 1.0)
	tw.tween_callback(_defaut_3)


func _defaut_3() -> void:
	if tw: tw.kill()

	tw = create_tween().set_loops()
	tw.tween_method(func (i: int) -> void:
		var x: float = 672.0 if i == 0 else 480.0
		texture.region = Rect2(x, 272.0 + (48 * i), 48.0, 48.0)
	, 0, 1, 1.0)


func _use_2() -> void:
	if tw: tw.kill()
	tw = create_tween()
	tw.tween_method(func (x: int) -> void:
		var j: int = 0 if x < 5 else 1
		var i: int = x if x < 5 else 0
		texture.region = Rect2(480.0 + (48 * i), 320.0 + (48 * j), 48.0, 48.0)
	, 0, 5, 1.0)


func _restore() -> void:
	if tw: tw.kill()
	tw = create_tween()

	tw.tween_method(func (x: float) -> void:
		var j: int = int(x / 5.0)
		var i: int = int(x) % 5
		texture.region = Rect2(480.0 + (48.0 * i), 320.0 + (48.0 * j), 48.0, 48.0)
	, 5.0, 0.0, 1.0)

	tw.tween_method(func (x: float) -> void:
		var j: int = int(x / 5.0)
		var i: int = int(x) % 5
		texture.region = Rect2(480.0 + (48.0 * i), 224.0 + (48.0 * j), 48.0, 48.0)
	, 7.0, 0.0, 1.0)
