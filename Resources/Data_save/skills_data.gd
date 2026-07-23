class_name SkillsData extends Resource

enum SkillsType {
	NONE,

	SWORD,
	ROLL,
	EYE_OF_HORUS,

	HAMMER,
	LUMINOUS_NECKLACE,
	ANUBISS_SHADOW_BRACELET,

	BUG_TRANSFORM,
	DASH,
	SPIRIT_RED_CHARTER,

	SPIRIT_BLUE_CHARTER,
	NECKLACE_OF_LIGHT
}

@export var sword: bool = false
@export var roll: bool = false
@export var eye_of_horus: bool = false

@export var hammer: bool = false
@export var luminous_necklace: bool = false
@export var anubiss_shadow_bracelet: bool = false

@export var bug_transform: bool = false
@export var dash: bool = false
@export var spirit_red_charter: bool = false

@export var spirit_blue_charter: bool = false
@export var necklace_of_light: bool = false


static func equipped_index_to_skill(skill: SkillsData.SkillsType) -> int:
	match skill:
		SkillsType.SWORD: return 0
		SkillsType.ROLL: return 0
		SkillsType.EYE_OF_HORUS: return 0

		SkillsType.HAMMER: return 1
		SkillsType.LUMINOUS_NECKLACE: return 1
		SkillsType.ANUBISS_SHADOW_BRACELET: return 1

		SkillsType.BUG_TRANSFORM: return 2
		SkillsType.DASH: return 2
		SkillsType.SPIRIT_RED_CHARTER: return 2

		_: return -1

'''	SPIRIT_BLUE_CHARTER,
	NECKLACE_OF_LIGHT'''
