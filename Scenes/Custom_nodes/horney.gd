class_name HorneyNode extends TextureRect

var tw: Tween

# Constante de puntos máximos por vasija
const MAX_POINTS: int = 15
# Puntos requeridos para efectuar 1 curación (Mitad de la vasija)
const POINTS_PER_USE: int = 7


func _ready() -> void:
	texture = texture.duplicate()
	'''_defaut_1()
	await Util.timerout(2)
	_defaut_2()
	await Util.timerout(3)
	_use_1()
	await Util.timerout(5)
	_use_2()'''



## --- ESTADOS VISUALES BASE ---

# Vasija no purificada (Sombra / Tono oscuro)
func _defaut_1() -> void:
	_kill_tween()
	texture.region = Rect2(480.0, 224.0, 48.0, 48.0)
	modulate = Color("303030ff")


# Vasija purificada y totalmente llena (15 pts -> Frame 0)
func _defaut_2() -> void:
	_kill_tween()
	modulate = Color("white")
	_set_frame_by_index(0)


# Vasija a la mitad 7 pts
func _defaut_3() -> void:
	_kill_tween()
	tw = create_tween().set_loops()
	tw.tween_method(func(i: int) -> void:
		var x: float = 672.0 if i == 0 else 480.0
		texture.region = Rect2(x, 272.0 + (48.0 * i), 48.0, 48.0)
	, 0, 1, 1.0)


# Vasija totalmente vacía (0 pts -> Frame 15)
func _set_empty() -> void:
	_kill_tween()
	_set_frame_by_index(15)


## --- CONSUMO (USO DE MIEL) ---

# Consumo 1: De Llena (15 pts) a Mitad (7 pts / Frame 8)
func _use_1() -> void:
	_kill_tween()
	tw = create_tween()
	tw.tween_method(func(x: int) -> void:
		_set_frame_by_index(x)
	, 0, 8, 1.0)
	tw.tween_callback(_defaut_3)


# Consumo 2: De Mitad (7 pts / Frame 8) a Vacía (0 pts / Frame 15)
func _use_2() -> void:
	_kill_tween()
	tw = create_tween()
	tw.tween_method(func(x: int) -> void:
		_set_frame_by_index(x)
	, 10, 15, 1.0)
	tw.tween_callback(_set_empty)


## --- RECARGA POR PANALES (SEÑAL) ---

func add_points_animated(current_points: int, added_points: int) -> void:
	_kill_tween()

	var old_pts: int = clamp(current_points - added_points, 0, MAX_POINTS)
	var new_pts: int = clamp(current_points, 0, MAX_POINTS)

	var start_frame: int = 15 - old_pts
	var target_frame: int = 15 - new_pts

	tw = create_tween()

	tw.tween_method(func(frame_idx: float) -> void:
		_set_frame_by_index(int(frame_idx))
	, float(start_frame), float(target_frame), 0.8)

	if new_pts >= MAX_POINTS:
		tw.tween_callback(_defaut_2)
	elif new_pts == POINTS_PER_USE:
		tw.tween_callback(_defaut_3)


## --- MÉTODOS AUXILIARES ---

# Coloca la textura en el frame exacto (0 al 15) respondiendo a las filas de 5 elementos
func _set_frame_by_index(idx: int) -> void:
	var clamp_idx: int = clamp(idx, 0, 15)
	var j: int = int(clamp_idx / 5.0)
	var i: int = clamp_idx % 5
	texture.region = Rect2(480.0 + (48.0 * i), 224.0 + (48.0 * j), 48.0, 48.0)


func _kill_tween() -> void:
	if tw and tw.is_running():
		tw.kill()
