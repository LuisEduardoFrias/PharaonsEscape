class_name PlayerData extends Resource

enum Player_direction { FRONT, BACK, LEFT, RIGHT }

signal add_heart
signal hurt_heart(damage: int)
signal restore_all_heart
signal retore_one_heart

signal add_horney
signal used_horney(index: int, is_one_use: bool)
signal purified_horney(index: int)
signal restore_horney(index: int, value: int)

@export var max_live: int = 3
@export var current_live: int = 3
@export var save_on: bool = false
@export var current_horney: Array[Horney] = []
@export var direction: Player_direction = Player_direction.FRONT
@export var position: Vector2 = Vector2(0.0, 0.0)
@export var equipped_skills: Array[SkillsData.SkillsType] = [
	SkillsData.SkillsType.NONE,
	SkillsData.SkillsType.NONE,
	SkillsData.SkillsType.NONE
]


#----------- HEART LIVE -----------------


func _hurt_heart(damage: int) -> void:
	if current_live > 0:
		current_live -= damage
		hurt_heart.emit(damage)


func _restore_all_heart() -> void:
	current_live = max_live
	restore_all_heart.emit()


func _restore_one_heart() -> void:
	if current_live == max_live:
		return
	current_live += 1
	retore_one_heart.emit()


func _add_heart() -> void:
	if max_live < 6:
		max_live += 1
		current_live = max_live
		add_heart.emit()


#-------------------- HORNEY POTION


func _add_horney() -> void:
	if current_horney.size() < 3:
		current_horney.append(Horney.new())
		Global.save()
		add_horney.emit()


func _purified_horney() -> void:
	for i:int in range(3):
		if current_horney.size() >= i:
			if not current_horney[i].is_purified:
				current_horney[i].is_purified = true
				Global.save()
				purified_horney.emit(i)
				break


func _use_horney() -> void:
	if current_live == max_live:
		return
	for i in range(current_horney.size() - 1, -1, -1):
		var obj = current_horney[i]
		if obj.is_purified and obj.value in [8, 16]:
			obj.value -= 8
			Global.save()
			used_horney.emit(i, obj.value == 8)
			_restore_one_heart()
			break


func _restore_horney(points: int) -> void:
	for i:int in range(3):
		var val =  current_horney[i].value
		if val <= 16:
			val += points
			var rest = val - 16
			var continue_: bool = false
			if rest >= 1:
				val -= rest
				continue_ = true
				points = rest
			current_horney[i].value += val
			restore_horney.emit(i, val)
			if not continue_:
				break
