@tool class_name Skill extends Node2D

@export var skill : SkillsData.SkillsType


signal set_skill()


func _ready() -> void:
	if Global.data.skills[Global.skill_to_str(skill)]:
		set_skill.emit() #cualquiera que esté asociado a este evento se ejecutará si la habilidad ya a sido tomada.
		call_deferred("queue_free")
	else:
		$area.body_entered.connect(activate_skill)


func activate_skill(body: Node2D) -> void:
	if body is Player:
		body.state_machine._on_child_transition(AnimationStateMachine.States.ADD_SKILL)

		var tween: Tween = get_tree().create_tween()
		tween.tween_property($GPUParticles2D, "speed_scale", 20.0, 2)
		tween.tween_callback(func () -> void: set_skill.emit())
		tween.tween_property($GPUParticles2D, "speed_scale", 0.0, 1)
		tween.tween_property($GPUParticles2D, "self_modulate", Color(0.912, 0.912, 0.912, 0.0), 0.5)
		tween.tween_callback(func () -> void :
			await get_tree().create_timer(0.5).timeout
			call_deferred("queue_free"))
