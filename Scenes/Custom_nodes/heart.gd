class_name Heart extends TextureRect

enum States { NORMAL, MUMMIFIED, STOPPED }
var tw: Tween

var state: int = States.MUMMIFIED


func _ready() -> void:
	texture = texture.duplicate()
	if material:
		material = material.duplicate()
	'''_defaut_1()
	await Util.timerout(3)
	_hurt_1()
	await Util.timerout(5)
	_hurt_2()
	await Util.timerout(5)
	_restore_partial()
	await Util.timerout(5)
	_hurt_2()
	await Util.timerout(5)
	_restore_full()'''


## --- ESTADOS DEFAULT (Bucle) ---

# Corazón normal latiendo
func _defaut_1() -> void:
	_kill_tween()
	state = States.NORMAL
	tw = create_tween().set_loops()
	tw.tween_method(func(i: int) -> void:
		texture.region = Rect2(128.0 + (32 * i), 384.0, 32.0, 32.0)
		var val: float = 1.1 if i%2==0 else 1.0
		scale = Vector2(val, val)
	, 0, 4, 1.0)
	tw.tween_property(self, "material:shader_parameter/gray_amount", 0.0, 1.0)


# Corazón vendado latiendo
func _defaut_2() -> void:
	_kill_tween()
	state = States.MUMMIFIED
	tw = create_tween().set_loops()
	tw.tween_method(func(i: int) -> void:
		texture.region = Rect2(128.0 + (32 * i), 448.0, 32.0, 32.0)
		var val: float = 1.1 if i%2==0 else 1.0
		scale = Vector2(val, val)
	, 0, 4, 1.0)
	tw.tween_property(self, "material:shader_parameter/gray_amount", 0.0, 1.0)


## --- ESTADOS DE DAÑO ---

# Primer golpe: Transición a vendado -> Pasa a _defaut_2
func _hurt_1() -> void:
	_kill_tween()
	tw = create_tween()
	tw.tween_method(func(i: int) -> void:
		var j: int = 32 if i < 5 else 64
		texture.region = Rect2(128.0 + (32 * i), 384.0 + j, 32.0, 32.0)
	, 0, 4, 1.0)
	tw.tween_callback(_defaut_2)


# Segundo golpe: Latiendo lento, entra escala de grises y se congela
func _hurt_2() -> void:
	_kill_tween()
	state = States.STOPPED
	tw = create_tween()
	tw.tween_method(func(i: int) -> void:
		texture.region = Rect2(128.0 + (32 * i), 448.0, 32.0, 32.0)
	, 0, 4, 1.0)

	tw.tween_property(self, "texture:region", Rect2(128.0, 448.0, 32.0, 32.0), 0.0)
	tw.tween_property(self, "material:shader_parameter/gray_amount", 1.0, 1.0)


## --- ESTADOS DE RESTAURACIÓN ---

# Restaurar 1 punto de vida (De sin vida a latiendo vendado)
func _restore_partial() -> void:
	_kill_tween()
	tw = create_tween()
	tw.tween_property(self, "material:shader_parameter/gray_amount", 0.0, 0.8)
	tw.tween_callback(_defaut_2)


# Restaurar vida completa (Quita escala de grises e invierte el vendaje hasta sanar)
func _restore_full() -> void:
	_kill_tween()
	tw = create_tween()

	tw.tween_property(self, "material:shader_parameter/gray_amount", 0.0, 0.5)

	tw.tween_method(func(i: int) -> void:
		var j: int = 64 if i > 2 else 32
		texture.region = Rect2(128.0 + (32 * i), 384.0 + j, 32.0, 32.0)
	, 4, 0, 1.0)

	tw.tween_callback(_defaut_1)


## --- MÉTODOS AUXILIARES ---

func _kill_tween() -> void:
	if tw and tw.is_running():
		tw.kill()
