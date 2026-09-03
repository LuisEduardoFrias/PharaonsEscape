class_name Live extends HBoxContainer

@onready var hearts: Array[Heart] = [
	$Control/heart,
	$Control2/heart2,
	$Control3/heart3]


func _ready() -> void:
	Global.data.player.add_heart.connect(add_heart)
	Global.data.player.hurt_heart.connect(hurt_heart)
	Global.data.player.restore_all_heart.connect(restore_all_heart)
	Global.data.player.retore_one_heart.connect(retore_one_heart)
	init_live()


func init_live() -> void:
	var current_live: int = Global.data.player.current_live

	for heart in hearts:
		heart.scale = Vector2.ZERO

	var tw: Tween = create_tween().set_parallel(true)
	for i in range(hearts.size()):
		var heart: Heart = hearts[i]
		var delay: float = i * 0.25

		tw.tween_property(heart, ^"scale", Vector2.ONE, 2.5)\
			.set_trans(Tween.TRANS_BACK)\
			.set_ease(Tween.EASE_OUT)\
			.set_delay(delay)

	await Util.timerout(0.5)

	var full_hearts_count: int = max(0, current_live - 3)

	for i in range((hearts.size() - 1), -1, -1):
		var heart: Heart = hearts[i]

		if i >= (hearts.size() - full_hearts_count):
			heart._defaut_1()
		elif i < current_live:
			heart._hurt_1()
		else:
			heart._hurt_2()


func add_heart() -> void:
	var max_live: int = Global.data.player.max_live

	var full_hearts_count: int = max(0, max_live - 3)

	for i in range(hearts.size()):
		var heart: Heart = hearts[i]

		var target_is_full: bool = i >= (hearts.size() - full_hearts_count)

		await Util.timerout(0.2)

		if target_is_full:
			heart._restore_full()
		else:
			heart._restore_partial()


func hurt_heart(_damage: int) -> void:
	#var current_live: int = Global.data.player.current_live

	for i in range(hearts.size(), -1, -1):
		var heart: Heart = hearts[i-1]

		if heart.state == Heart.States.NORMAL: heart._hurt_1(); break
		elif heart.state == Heart.States.MUMMIFIED: heart._hurt_2(); break


func restore_all_heart() -> void:
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


func retore_one_heart() -> void:
	for i in range(hearts.size()):
		var heart: Heart = hearts[i]
		if heart.state == Heart.States.STOPPED: heart._defaut_2(); break
		elif heart.state == Heart.States.MUMMIFIED: heart._defaut_1(); break
