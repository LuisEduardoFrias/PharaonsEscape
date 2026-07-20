@tool extends Control

@onready var panel: Panel = $panel
@onready var img: TextureRect = $panel/MarginContainer/HBoxContainer/texture
@onready var desc: Label = $panel/MarginContainer/HBoxContainer/Label

@export var active: bool = false:
	set(val):
		active = val
		if not is_node_ready(): await ready
		if val:
			_show_skill(SkillsData.SkillsType.SWORD)


var is_active: bool = false

func _show_skill(skill: SkillsData.SkillsType) -> void:
	if not is_active:
		is_active = true
		change_img(skill)
		var tw: Tween = create_tween()
		tw.tween_property(panel, ^"position:x", panel.position.x - 250.0, 1.0)
		tw.tween_interval(3.0)
		tw.tween_property(panel, ^"position:x", panel.position.x, 1.0)
		tw.tween_callback(func()->void: is_active = false)


func _show_coin() -> void:
	if not is_active:
		is_active = true
		img.texture.region = Rect2(288.0, 160.0, 32.0, 32.0)
		desc.text = "Daga eterna."
		var tw: Tween = create_tween()
		tw.tween_property(panel, ^"position:x", panel.position.x - 250.0, 1.0)
		tw.tween_interval(3.0)
		tw.tween_property(panel, ^"position:x", panel.position.x, 1.0)
		tw.tween_callback(func()->void: is_active = false)


func change_img(skill: SkillsData.SkillsType) -> void:
	match skill:
		SkillsData.SkillsType.SWORD:
			img.texture.region = Rect2(288.0, 160.0, 32.0, 32.0)
			desc.text = "Daga eterna."
		SkillsData.SkillsType.ROLL:
			img.texture.region = Rect2(288.0, 160.0, 32.0, 32.0)
			desc.text = "Daga eterna."
		SkillsData.SkillsType.EYE_OF_HORUS:
			img.texture.region = Rect2(288.0, 160.0, 32.0, 32.0)
			desc.text = "Daga eterna."

		SkillsData.SkillsType.HAMMER:
			img.texture.region = Rect2(0.0, 0.0, 32.0, 32.0)
			desc.text = "Daga eterna."
		SkillsData.SkillsType.LUMINOUS_NECKLACE:
			img.texture.region = Rect2(0.0, 0.0, 32.0, 32.0)
			desc.text = "Daga eterna."
		SkillsData.SkillsType.ANUBISS_SHADOW_BRACELET:
			img.texture.region = Rect2(0.0, 0.0, 32.0, 32.0)
			desc.text = "Daga eterna."

		SkillsData.SkillsType.BUG_TRANSFORM:
			img.texture.region = Rect2(0.0, 0.0, 32.0, 32.0)
			desc.text = "Daga eterna."
		SkillsData.SkillsType.DASH:
			img.texture.region = Rect2(0.0, 0.0, 32.0, 32.0)
			desc.text = "Daga eterna."
		SkillsData.SkillsType.SPIRIT_RED_CHARTER:
			img.texture.region = Rect2(0.0, 0.0, 32.0, 32.0)
			desc.text = "Daga eterna."

		SkillsData.SkillsType.SPIRIT_BLUE_CHARTER:
			img.texture.region = Rect2(0.0, 0.0, 32.0, 32.0)
			desc.text = "Daga eterna."
		SkillsData.SkillsType.NECKLACE_OF_LIGHT:
			img.texture.region = Rect2(0.0, 0.0, 32.0, 32.0)
			desc.text = "Daga eterna."
		_:
			img.texture.region = Rect2(0.0, 0.0, 32.0, 32.0)
			desc.text = "None."
