class_name PlayerData extends Resource

enum Player_direction { FRONT, BACK, LEFT, RIGHT }

signal hurt(damage: int)
signal restore_all_live
signal retore_one_live

signal get_horney
signal used_horney
signal purified_horney(index: int)
signal get_points_horney

@export var max_live: int = 3
@export var current_live: int = 3
@export var save_on: bool = false
@export var current_horney: Array[Dictionary] = []
@export var direction: Player_direction = Player_direction.FRONT
@export var position: Vector2 = Vector2(0.0, 0.0)
@export var equipped_skills: Array[SkillsData.SkillsType] = [
	SkillsData.SkillsType.NONE,
	SkillsData.SkillsType.NONE,
	SkillsData.SkillsType.NONE
]


#----------------------------------- HEART LIVE

func _hurt(damage: float) -> void:
	current_live -= int(damage )
	hurt.emit(current_live)


func _retore_all_live() -> void:
	current_live = max_live
	restore_all_live.emit()


func _retore_one_live() -> void:
	if current_live == max_live:
		return
	current_live += 1
	retore_one_live.emit()


#-------------------- HORNEY POTION

func _get_horney() -> void:
	if current_horney.size() < 3:
		current_horney.append(
			{ "purified": false, "use": 2, "points": 15 }
		)
		get_horney.emit()


func _purified_horney() -> void:
	for index:int in range(3):
		if current_horney[index].purified == false:
			current_horney[index].purified = true
			purified_horney.emit(index)
			break


func use_horney() -> void:
	for i in range(current_horney.size() - 1, -1, -1):
		var dic = current_horney[i]
		if dic.use in [2, 1]:
			dic.use -= 1
			# retore One live
			used_horney.emit()
			break


func _get_points_horney(_points: int) -> void:
	pass
