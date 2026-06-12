class_name PlayerData extends Resource

enum Player_direction { FRONT, BACK, LEFT, RIGHT }


@export var current_live: int = 6
@export var save_on: bool = false
@export var direction: Player_direction = Player_direction.FRONT
@export var position: Vector2 = Vector2(0.0, 0.0)
@export var equipped_skills: Array[SkillsData.SkillsType] = [
	SkillsData.SkillsType.HAMMER,
	SkillsData.SkillsType.NECKLACE_OF_LIGHT,
	SkillsData.SkillsType.SPIRIT_BLUE_CHARTER
]

'''
	SkillsData.SkillsType.ANUBISS_SHADOW_BRACELET,
	SkillsData.SkillsType.ROLL,
	SkillsData.SkillsType.HAMMER
	'''
