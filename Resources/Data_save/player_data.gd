class_name PlayerData extends Resource

enum Player_direction { FRONT, BACK, LEFT, RIGHT }

signal hurt(damage: int)
signal restore_all_live
signal used_horney()

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


#-----------------------------------

func _hurt(damage: float) -> void:
	current_live -= int(damage )
	hurt.emit(current_live)


func _retore_live() -> void:
	current_live = 3
	restore_all_live.emit()


#--------------------


func get_horney() -> void:
	if current_horney.size() < 3:
		current_horney.append(
			{ "purified": false, "use": 2 }
		)


func use_horney() -> void:
	for i in range(current_horney.size() - 1, -1, -1):
		var dic = current_horney[i]
		if dic.use in [2, 1]:
			dic.use -= 1
			# retore One live
			used_horney.emit()
			break


func purified() -> void:
	for obj in current_horney:
		if obj.purified == false:
			obj.purified = true
			break
