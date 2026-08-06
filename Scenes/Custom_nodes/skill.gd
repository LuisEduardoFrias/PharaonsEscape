@tool class_name Skill extends Node2D

@export var skill : SkillsData.SkillsType
@export var anim: AnimatedSprite2D


@onready var area: Area2D = $area

signal set_skill()


func _ready() -> void:
	if Global.data.skills.has_skill(skill):
		set_skill.emit() #cualquiera que esté asociado a este evento se ejecutará si la habilidad ya a sido tomada.
		call_deferred("queue_free")
	else:
		$area.body_entered.connect(activate_skill)


func activate_skill(body: Node2D) -> void:
	if body is Player:
		area.set_deferred("monitoring", false)
		anim.queue_free()
		if body.is_jumping: await body.state_machine.current_state.jump_finished
		body._input_physics_off(true)
		await body.move_to_kinematic_point(global_position)
		body.state_machine._on_child_transition(AnimationStateMachine.States.ADD_SKILL)

		var tween: Tween = get_tree().create_tween()
		tween.tween_property($GPUParticles2D, "speed_scale", 20.0, 2)
		tween.tween_callback(func () -> void:
			Global.add_skill(skill)
			set_skill.emit())
		tween.tween_property($GPUParticles2D, "speed_scale", 0.0, 1)
		tween.tween_property($GPUParticles2D, "self_modulate", Color(0.912, 0.912, 0.912, 0.0), 0.5)
		tween.tween_callback(func () -> void :
			await get_tree().create_timer(0.5).timeout
			body._input_physics_off(false)
			call_deferred("queue_free")
			)
