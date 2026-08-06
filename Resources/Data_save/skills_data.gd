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


# Diccionario exportado para verlo y editarlo en el Inspector
@export var unlocked_skills: Dictionary[SkillsType, bool] = {
	SkillsType.SWORD: false,
	SkillsType.ROLL: false,
	SkillsType.EYE_OF_HORUS: false,

	SkillsType.HAMMER: false,
	SkillsType.LUMINOUS_NECKLACE: false,
	SkillsType.ANUBISS_SHADOW_BRACELET: false,

	SkillsType.BUG_TRANSFORM: false,
	SkillsType.DASH: false,
	SkillsType.SPIRIT_RED_CHARTER: false,

	SkillsType.SPIRIT_BLUE_CHARTER: false,
	SkillsType.NECKLACE_OF_LIGHT: false,
}


func unlock_skill(type: SkillsType) -> void:
	if not unlocked_skills.get(type, false):
		unlocked_skills[type] = true


func has_skill(type: SkillsType) -> bool:
	return  unlocked_skills.get(type, false)


static func equipped_index_to_skill(skill: SkillsData.SkillsType) -> Dictionary:
	match skill:
		SkillsType.SWORD: 					return { "container_id": 0, "index": 1, "activated": Global.data.skills.unlocked_skills.get(SkillsType.SWORD) }
		SkillsType.ROLL: 					return { "container_id": 0, "index": 2, "activated": Global.data.skills.unlocked_skills.get(SkillsType.ROLL) }
		SkillsType.EYE_OF_HORUS: 			return { "container_id": 0, "index": 3, "activated": Global.data.skills.unlocked_skills.get(SkillsType.EYE_OF_HORUS) }

		SkillsType.HAMMER: 					return { "container_id": 1, "index": 1, "activated": Global.data.skills.unlocked_skills.get(SkillsType.HAMMER) }
		SkillsType.LUMINOUS_NECKLACE:		return { "container_id": 1, "index": 2, "activated": Global.data.skills.unlocked_skills.get(SkillsType.LUMINOUS_NECKLACE) }
		SkillsType.NECKLACE_OF_LIGHT: 		return { "container_id": 1, "index": 2, "activated": Global.data.skills.unlocked_skills.get(SkillsType.NECKLACE_OF_LIGHT) }
		SkillsType.ANUBISS_SHADOW_BRACELET: return { "container_id": 1, "index": 3, "activated": Global.data.skills.unlocked_skills.get(SkillsType.ANUBISS_SHADOW_BRACELET) }

		SkillsType.BUG_TRANSFORM: 			return { "container_id": 2, "index": 1, "activated": Global.data.skills.unlocked_skills.get(SkillsType.BUG_TRANSFORM) }
		SkillsType.DASH: 					return { "container_id": 2, "index": 2, "activated": Global.data.skills.unlocked_skills.get(SkillsType.DASH) }
		SkillsType.SPIRIT_RED_CHARTER: 		return { "container_id": 2, "index": 3, "activated": Global.data.skills.unlocked_skills.get(SkillsType.SPIRIT_RED_CHARTER) }
		SkillsType.SPIRIT_BLUE_CHARTER: 	return { "container_id": 2, "index": 3, "activated": Global.data.skills.unlocked_skills.get(SkillsType.SPIRIT_BLUE_CHARTER) }

		_:									return { "container_id": -1, "index": 0, "activated": null }
