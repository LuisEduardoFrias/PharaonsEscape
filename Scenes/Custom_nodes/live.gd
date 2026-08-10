extends MarginContainer

@onready var heart1: Heart = $panel/TextureRect/MarginContainer/VBoxContainer/HBoxContainer2/Control/heart
@onready var heart2: Heart = $panel/TextureRect/MarginContainer/VBoxContainer/HBoxContainer2/Control2/heart2
@onready var heart3: Heart = $panel/TextureRect/MarginContainer/VBoxContainer/HBoxContainer2/Control3/heart3

@onready var hearts: Array[Heart] = [heart1, heart2, heart3]


func _ready() -> void:
	Global.player_data.hurt.connect(hurt)
	Global.player_data.restore_all_live.connect(restore_all_live)
	init_live()


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

	for i in range(hearts.size()):
		var heart: Heart = hearts[i]

		if i >= (hearts.size() - full_hearts_count):
			heart._defaut_1()
		elif i < current_live:
			heart._hurt_1()
		else:
			heart._hurt_2()


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


## Método auxiliar para determinar qué estado (0, 1 o 2) le corresponde a un corazón 'i' dada una cantidad de vida
func _get_heart_state(index: int, live_amount: int) -> int:
	var full_hearts_count: int = max(0, live_amount - 3)

	if index >= (hearts.size() - full_hearts_count):
		return 2
	elif index < live_amount:
		return 1
	else:
		return 0


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
