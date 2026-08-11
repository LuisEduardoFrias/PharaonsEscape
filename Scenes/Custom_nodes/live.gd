class_name Live extends MarginContainer

@onready var heart1: Heart = $panel/TextureRect/MarginContainer/VBoxContainer/HBoxContainer2/Control/heart
@onready var heart2: Heart = $panel/TextureRect/MarginContainer/VBoxContainer/HBoxContainer2/Control2/heart2
@onready var heart3: Heart = $panel/TextureRect/MarginContainer/VBoxContainer/HBoxContainer2/Control3/heart3

@onready var horney1: Horney = $panel/TextureRect/MarginContainer/VBoxContainer/HBoxContainer/Control/horney
@onready var horney2: Horney = $panel/TextureRect/MarginContainer/VBoxContainer/HBoxContainer/Control2/horney2
@onready var horney3: Horney = $panel/TextureRect/MarginContainer/VBoxContainer/HBoxContainer/Control3/horney3

@onready var hearts: Array[Heart] = [heart1, heart2, heart3]
@onready var horneys: Array[Horney] = [horney1, horney2, horney3]


func _ready() -> void:
	Global.player_data.hurt.connect(hurt)
	Global.player_data.restore_all_live.connect(restore_all_live)
	Global.player_data.purified_horney.connect(_on_horney_purified)

	init_live()
	init_horney()


func init_live() -> void:
	var current_live: int = Global.player_data.current_live

	for heart in hearts:
		heart.scale = Vector2.ZERO

	await Util.timerout(3)

	var tw: Tween = create_tween().set_parallel(true)
	for i in range(hearts.size()):
		var heart: Heart = hearts[i]
		var delay: float = i * 0.25

		tw.tween_property(heart, ^"scale", Vector2.ONE, 2.5)\
			.set_trans(Tween.TRANS_BACK)\
			.set_ease(Tween.EASE_OUT)\
			.set_delay(delay)

	await Util.timerout(2)

	var full_hearts_count: int = max(0, current_live - 3)

	for i in range((hearts.size() - 1), -1, -1):
		var heart: Heart = hearts[i]

		if i >= (hearts.size() - full_hearts_count):
			heart._defaut_1()
		elif i < current_live:
			heart._hurt_1()
		else:
			heart._hurt_2()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_use_horney"):
		use_horney()


## Consumo de miel en orden: Izquierda a Derecha (0 -> 1 -> 2)
func use_horney() -> void:
	var horney_data: Array = Global.data.player.current_horney

	for i in range(horney_data.size()):
		var item: Dictionary = horney_data[i]

		if item.purified and item.get("use", 0) > 0:
			item.use -= 1

			if item.use == 1:
				item.points = Horney.POINTS_PER_USE
				horneys[i]._use_1()

			elif item.use == 0:
				item.points = 0
				horneys[i]._use_2()

			Global.player_data._retore_one_live()

			break


func init_horney() -> void:
	var horney_data: Array = Global.data.player.current_horney

	for horney in horneys:
		horney.scale = Vector2.ZERO

	if horney_data.is_empty():
		return

	for i in range(min(horney_data.size(), horneys.size())):
		var horney: Horney = horneys[i]
		var data: Dictionary = horney_data[i]

		var is_purified: bool = data.get("purified", false)
		var pts: int = data.get("points", 0)

		if not is_purified:
			horney._defaut_1()
		else:
			if pts >= 15:
				horney._defaut_2()
			elif pts == 7:
				horney._defaut_3()
			elif pts == 0:
				horney._set_empty()
			else:
				horney._set_frame_by_index(15 - pts)

	var tw: Tween = create_tween().set_parallel(true)
	for i in range(min(horney_data.size(), horneys.size())):
		var horney: Horney = horneys[i]
		var delay: float = i * 0.2

		tw.tween_property(horney, ^"scale", Vector2.ONE, 1.5)\
			.set_trans(Tween.TRANS_BACK)\
			.set_ease(Tween.EASE_OUT)\
			.set_delay(delay)


#---------------------------


func hurt(_damage: int) -> void:
	var current_live: int = Global.player_data.current_live
	var previous_live: int = current_live + _damage

	for i in range(hearts.size()):
		var heart: Heart = hearts[i]

		var prev_state: int = _get_heart_state(i, previous_live)
		var curr_state: int = _get_heart_state(i, current_live)

		if curr_state < prev_state:
			if curr_state == 0:
				heart._hurt_2()
			elif curr_state == 1:
				heart._hurt_1()


func _get_heart_state(index: int, live_amount: int) -> int:
	var full_hearts_count: int = max(0, live_amount - 3)

	if index >= (hearts.size() - full_hearts_count):
		return 2
	elif index < live_amount:
		return 1
	else:
		return 0


#---------------------------

func update_live() -> void:
	var max_live: int = Global.player_data.max_live

	var full_hearts_count: int = max(0, max_live - 3)

	for i in range(hearts.size()):
		var heart: Heart = hearts[i]

		var target_is_full: bool = i >= (hearts.size() - full_hearts_count)

		await Util.timerout(0.2)

		if target_is_full:
			heart._restore_full()
		else:
			heart._restore_partial()



func restore_all_live() -> void:
	var max_live: int = Global.player_data.max_live

	var full_hearts_count: int = max(0, max_live - 3)

	for i in range(hearts.size()):
		var heart: Heart = hearts[i]

		var target_is_full: bool = i >= (hearts.size() - full_hearts_count)

		await Util.timerout(0.2)

		if target_is_full:
			heart._restore_full()
		else:
			heart._restore_partial()


## Se conecta a la señal cuando se crea/obtiene un NUEVO horney
func _on_horney_added() -> void:
	var horney_data: Array = Global.data.player.current_horney
	if horney_data.is_empty():
		return

	var new_index: int = horney_data.size() - 1
	if new_index >= horneys.size():
		return

	var horney: Horney = horneys[new_index]
	var data: Dictionary = horney_data[new_index]

	var is_purified: bool = data.get("purified", false)
	var pts: int = data.get("points", 0)

	if not is_purified:
		horney._defaut_1()
	else:
		horney.update_points(pts)

	horney.scale = Vector2.ZERO
	var tw: Tween = create_tween()
	tw.tween_property(horney, ^"scale", Vector2.ONE, 1.5)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)




## Se conecta a la señal cuando se PURIFICA una vasija
func _on_horney_purified(_index: int) -> void:
	var horney_data: Array = Global.data.player.current_horney
	if horney_data.is_empty():
		return

	_sort_horney_data_left_to_right(horney_data)

	update_horney_ui()


## Función auxiliar que organiza los datos de menor a mayor contenido (Izquierda -> Derecha)
func _sort_horney_data_left_to_right(horney_data: Array) -> void:
	for i in range(horney_data.size()):
		for j in range(i + 1, horney_data.size()):
			if horney_data[i]["points"] > horney_data[j]["points"]:
				var temp: Dictionary = horney_data[i]
				horney_data[i] = horney_data[j]
				horney_data[j] = temp


## Actualiza la representación visual de cada nodo Horney en base al Array de datos
func update_horney_ui() -> void:
	var horney_data: Array = Global.data.player.current_horney

	for i in range(horneys.size()):
		if i >= horney_data.size():
			break

		var data: Dictionary = horney_data[i]
		var horney_node: Horney = horneys[i]

		if not data.get("purified", false):
			horney_node._defaut_1()
			continue

		horney_node.modulate = Color("white")

		match data["points"]:
			15: horney_node._defaut_2()
			7: horney_node._defaut_3()
			0: horney_node._set_empty()
			_:
				horney_node._kill_tween()
				horney_node._set_frame_by_index(15 - data["points"])
