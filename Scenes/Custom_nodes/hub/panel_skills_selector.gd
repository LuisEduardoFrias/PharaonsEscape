extends Panel

@export_range(0, 2) var container_index: int = 0

@onready var btn: Button = $btn_select
@onready var tr_order: Array[Dictionary] = [
	{ "node": $VBoxContainer/texture_rect, "activated": true, "skill": SkillsData.SkillsType.NONE },
	{ "node": $VBoxContainer/texture_rect2, "activated": true, "skill": SkillsData.SkillsType.NONE },
	{ "node": $VBoxContainer/texture_rect3, "activated": true, "skill": SkillsData.SkillsType.NONE }
]

const SPEED_SELECT = 0.3


func _ready() -> void:
	for obj in tr_order:
		obj.node.texture = obj.node.texture.duplicate()
	Global.added_skill.connect(_select_skill)
	_equipped()

'''
	await Util.timerout(4)
	_select_skill(SkillsData.SkillsType.BUG_TRANSFORM)
'''


func _on_btn_select_pressed() -> void:
	_select()


func _select_skill(skill: SkillsData.SkillsType) -> void:
	var dic: Dictionary = SkillsData.equipped_index_to_skill(skill)
	if dic.container_id == container_index:
		Global.equipped_skill(skill)
		var tw: Tween = create_tween().set_loops(3)
		tw.tween_method(func (i: int) -> void:
			tr_order[1].node.texture.region =  Rect2(64.0 * i, 704.0, 64.0, 64.0),
		0, 11, 0.4)
		await tw.finished
		_equipped()


func _select() -> void:
	var active_items: Array[Dictionary] = tr_order.filter(func(item): return item["activated"])
	var active_count: int = active_items.size()

	if active_count < 2:
		return

	btn.disabled = true
	var tw: Tween = create_tween()

	if active_count == 2:
		var pos_0: Vector2 = active_items[0].node.position
		var pos_1: Vector2 = active_items[1].node.position

		tw.parallel().tween_property(active_items[0].node, ^"position", pos_1, SPEED_SELECT)
		tw.parallel().tween_property(active_items[1].node, ^"position", pos_0, SPEED_SELECT)

		var idx_0: int = tr_order.find(active_items[0])
		var idx_1: int = tr_order.find(active_items[1])
		tr_order[idx_0] = active_items[1]
		tr_order[idx_1] = active_items[0]

	elif active_count == 3:
		tw.parallel().tween_property(tr_order[0].node, ^"position", Vector2(0.0, 156.0), 0.0)
		tw.parallel().tween_property(tr_order[1].node, ^"position", Vector2(0.0, 0.0), SPEED_SELECT)
		tw.parallel().tween_property(tr_order[2].node, ^"position", Vector2(0.0, 78.0), SPEED_SELECT)

		var aux: Dictionary = tr_order[0]
		tr_order[0] = tr_order[1]
		tr_order[1] = tr_order[2]
		tr_order[2] = aux

	Global.equipped_skill(tr_order[1].skill)
	await tw.finished
	btn.disabled = false


func _equipped() -> void:
	for skill_name: String in SkillsData.SkillsType:
		var dic: Dictionary = SkillsData.equipped_index_to_skill(SkillsData.SkillsType[skill_name])

		if dic.container_id == container_index:
			tr_order[dic.index-1].activated = dic.activated
			var skill_val: SkillsData.SkillsType = SkillsData.SkillsType[skill_name] if dic.activated else SkillsData.SkillsType.NONE
			tr_order[dic.index-1].node.texture.region = _skill_to_rect(skill_val)
			tr_order[dic.index-1].skill = skill_val

	var eq: SkillsData.SkillsType = Global.data.player.equipped_skills[container_index]
	var dict: Dictionary = SkillsData.equipped_index_to_skill(eq)

	if not dict.index in [-1, 2]:
		if dict.index == 1:
			var aux = tr_order[0]
			tr_order[0] = tr_order[2]
			tr_order[2] = tr_order[1]
			tr_order[1] = aux
		else:
			var aux_2 = tr_order[2]
			tr_order[2] = tr_order[0]
			tr_order[0] = tr_order[1]
			tr_order[1] = aux_2

		$VBoxContainer.move_child(tr_order[0].node, 0)
		$VBoxContainer.move_child(tr_order[1].node, 1)
		$VBoxContainer.move_child(tr_order[2].node, 2)


func _skill_to_rect(skill: SkillsData.SkillsType) -> Rect2:
	match skill:
		SkillsData.SkillsType.ANUBISS_SHADOW_BRACELET:	return Rect2(0.0, 0.0, 64.0, 64.0)
		SkillsData.SkillsType.BUG_TRANSFORM:			return Rect2(0.0, 64.0, 64.0, 64.0)
		SkillsData.SkillsType.DASH:						return Rect2(0.0, 128.0, 64.0, 64.0)
		SkillsData.SkillsType.EYE_OF_HORUS: 			return Rect2(0.0, 192.0, 64.0, 64.0)
		SkillsData.SkillsType.SPIRIT_BLUE_CHARTER:		return Rect2(0.0, 256.0, 64.0, 64.0)
		SkillsData.SkillsType.SPIRIT_RED_CHARTER: 		return Rect2(0.0, 320.0, 64.0, 64.0)
		SkillsData.SkillsType.HAMMER: 					return Rect2(0.0, 384.0, 64.0, 64.0)
		SkillsData.SkillsType.LUMINOUS_NECKLACE: 		return Rect2(0.0, 448.0, 64.0, 64.0)
		SkillsData.SkillsType.NECKLACE_OF_LIGHT: 		return Rect2(0.0, 512.0, 64.0, 64.0)
		SkillsData.SkillsType.ROLL: 					return Rect2(0.0, 576.0, 64.0, 64.0)
		SkillsData.SkillsType.SWORD: 					return Rect2(0.0, 640.0, 64.0, 64.0)
		_:												return Rect2(0.0, 704.0, 64.0, 64.0)
