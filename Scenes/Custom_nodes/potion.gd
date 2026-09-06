class_name Potions extends HBoxContainer

@onready var horneys: Array[HorneyNode] = [
	$Control/horney,
	$Control2/horney2,
	$Control3/horney3]


func _ready() -> void:
	Global.data.player.add_horney.connect(add_horney)
	Global.data.player.used_horney.connect(used_horney)
	Global.data.player.purified_horney.connect(purified_horney)
	Global.data.player.restore_horney.connect(restore_horney)

	init_horney(Global.data.player.current_horney)


func init_horney(horney_data: Array[Horney]) -> void:
	for horney in horneys:
		horney.scale = Vector2.ZERO

	if horney_data.is_empty():
		return

	for i in range(min(horney_data.size(), horneys.size())):
		var horney: HorneyNode = horneys[i]
		var data: Horney = horney_data[i]

		var is_purified: bool = data.is_purified
		var pts: int = data.value

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
		var horney: HorneyNode = horneys[i]
		var delay: float = i * 0.2

		tw.tween_property(horney, ^"scale", Vector2.ONE, 1.5)\
			.set_trans(Tween.TRANS_BACK)\
			.set_ease(Tween.EASE_OUT)\
			.set_delay(delay)


func add_horney() -> void:
	var horney_data: Array = Global.data.player.current_horney
	if horney_data.is_empty():
		return

	var new_index: int = horney_data.size() - 1
	if new_index >= horneys.size():
		return

	var horney: HorneyNode = horneys[new_index]
	var data: Horney = horney_data[new_index]

	var is_purified: bool = data.is_purified
	var pts: int = data.value

	if not is_purified:
		horney._defaut_1()
	else:
		horney.update_points(pts)

	horney.scale = Vector2.ZERO
	var tw: Tween = create_tween()
	tw.tween_property(horney, ^"scale", Vector2.ONE, 1.5)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)


func used_horney(index: int, is_one_use: bool) -> void:
	if is_one_use: horneys[index]._use_1()
	else: horneys[index]._use_2()


func purified_horney(_index: int) -> void:
	var horney_data: Array = Global.data.player.current_horney
	if horney_data.is_empty():
		return
	_sort_horney_data_left_to_right(horney_data)
	update_horney_ui()


func restore_horney(_index: int, _value: int) -> void: pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_use_horney"):
		Global.data.player._use_horney()


## Función auxiliar que organiza los datos de menor a mayor contenido (Izquierda -> Derecha)
func _sort_horney_data_left_to_right(horney_data: Array[Horney]) -> void:
	for i in range(horney_data.size()):
		for j in range(i + 1, horney_data.size()):
			if horney_data[i].value > horney_data[j].value:
				var temp: Horney = horney_data[i]
				horney_data[i] = horney_data[j]
				horney_data[j] = temp


## Actualiza la representación visual de cada nodo Horney en base al Array de datos
func update_horney_ui() -> void:
	var horney_data: Array = Global.data.player.current_horney

	for i in range(horneys.size()):
		if i >= horney_data.size():
			break

		var data: Horney = horney_data[i]
		var horney_node: HorneyNode = horneys[i]

		if not data.is_purified:
			horney_node._defaut_1()
			continue

		horney_node.modulate = Color("white")

		match data.value:
			15: horney_node._defaut_2()
			7: horney_node._defaut_3()
			0: horney_node._set_empty()
			_:
				horney_node._kill_tween()
				horney_node._set_frame_by_index(15 - data.value)
