class_name Player2 extends Entity

@onready var camera: CustomCamera = $camera
@onready var audio: AudioStreamPlayer2D = $audio_stream_player
@onready var static_body_player : StaticBody2D = $static_body_player
@onready var ray_cast: RayCast2D = $ray_cast

enum States { STATIC, FALL, NORMAL }

signal anubiss_bracelet(on: bool) #se emite cuando activa o desactiva el brazalete oscuro

var live:Node = null
var current_state: States = States.NORMAL:
	set(val):
		current_state = val
		if val == States.STATIC or val == States.FALL: ControlerManager.disabled = true
		else : ControlerManager.disabled = false
var disabled_joystick: bool = false
var wall_gap: BaseWall = null # hueco en la pared en el que se puede rodar
var dialogue_trigger: DialogueTrigger = null # para los dialogos
var interactive_obj: Object_ = null # para objetos con interacion
var platform_push: Vector2 = Vector2.ZERO
var is_eye_horus_enable: bool = false
var audio_fall: AudioStream = preload("res://Audio/player_fall.wav")
var allow_attack: bool = true # Valida si se puede atacar
var allow_hurt: bool = true # Valida si se puede recibir daño
var add_equipped_skill: Array # [Global.Skills]
var anubiss_bracelet_on: bool = false # Verifica la activacion del brazalete oscuro


func _ready() -> void:
	super()
	add_equipped_skill = Global.data.player.equipped_skills

	live = get_tree().get_first_node_in_group("live")
	var ui: UI = get_tree().get_first_node_in_group("ui")

	if live: live.restore(6)

	if ui:
		ui.equipped_skill.connect(func (skill: SkillsData.SkillsType) -> void:
			add_equipped_skill = Global.data.player.equipped_skills

			if skill != SkillsData.SkillsType.ANUBISS_SHADOW_BRACELET and anubiss_bracelet_on:
				anubiss_shadow_bracelet(false)
		)


func _physics_process(_delta: float) -> void:
	if current_state == States.STATIC or current_state == States.FALL:
		velocity = Vector2.ZERO
		return

	if not disabled_joystick:
		current_direction = ControlerManager.get_direction()
		if current_direction != Vector2.ZERO: old_direction = current_direction

	velocity = platform_push + (current_direction * speed)

	side_effects()
	move_and_slide()
	platform_push = Vector2.ZERO


func _input(event: InputEvent) -> void:
	if ControlerManager.disabled: return

	if not ControlerManager.touch_controls_enabled: return

	if not ControlerManager.target_viewport: return

	if event.is_action_pressed("ui_action_one"):
		var one: SkillsData.SkillsType  = add_equipped_skill[0]
		if one != SkillsData.SkillsType.NONE:
			call(Global.skill_to_str(one))
	if event.is_action_pressed("ui_action_two"):
		var two:SkillsData.SkillsType = add_equipped_skill[1]
		if two != SkillsData.SkillsType.NONE:
			call(Global.skill_to_str(two))
	if event.is_action_pressed("ui_action_three"):
		var three: SkillsData.SkillsType = add_equipped_skill[2]
		if three != SkillsData.SkillsType.NONE:
			call(Global.skill_to_str(three))
	if event.is_action_pressed("ui_action_four"):
		state_machine.on_child_transition("interact")


func side_effects() -> void:
	match current_direction:
		Vector2.UP:
			ray_cast.target_position = Vector2(0.0, -8.0)
		Vector2.DOWN:
			ray_cast.target_position = Vector2(0.0, 8.0)
		Vector2.RIGHT:
			ray_cast.target_position = Vector2(14.0, 0.0)
			$effects.flip_h = true
			$container_hit.scale.x = -1.0
			sprite_node.flip_h = true
		Vector2.LEFT:
			ray_cast.target_position = Vector2(-14.0, 0.0)
			$effects.flip_h = false
			$container_hit.scale.x = 1.0
			sprite_node.flip_h = false


func intermittency(duration: float = 1.0, callback: Callable = Callable()) -> void:
	var tw: Tween = create_tween().set_loops()

	tw.tween_property(self, "modulate:a", 0.0, 0.1)
	tw.tween_property(self, "modulate:a", 1.0, 0.1)

	await get_tree().create_timer(duration).timeout

	tw.kill()
	modulate.a = 1.0
	if callback.is_valid(): callback.call_deferred()


func add_skill(callback: Callable) -> void:
	current_state = States.STATIC

	if current_direction == Vector2.UP or current_direction == Vector2.DOWN:
		$effects.play("add_skill_front")
	else:
		$effects.play("add_skill_side")

	var tween: Tween = get_tree().create_tween()
	tween.tween_property($effects,"speed_scale", 10.0, 3)
	tween.tween_callback(func () -> void:
		$effects.play("off")
		callback.call()
		current_state = States.NORMAL
	)


## efectos y acciones del martillo
func hammer_attack() -> void:
	if wall_gap:
		wall_gap.unblock()


func move_to_(_position: Vector2, time: float = 1.0) -> void:
	current_state = States.STATIC
	playback.travel("walk")

	var tween: Tween = create_tween()
	tween.tween_property(self, "position", _position + Vector2(0.0, -16.0), time)
	tween.tween_callback(func () -> void: current_state = States.NORMAL)


func hurt(ps: Vector2, damage: int = 1) -> void:
	if allow_hurt:
		$StateMachine.on_child_transition("hurt", { "ps": ps, "damage": damage })


func _on_hit_area_entered(area: Area2D) -> void:
	if area.get_parent() is Switch:
		area.get_parent().hurt()


func _on_active_dialog_area_entered(area: Area2D) -> void:
	if area is DialogueTrigger:
		if area.get_parent() is Object_: interactive_obj = area.get_parent()
		else: dialogue_trigger = area


func _on_active_dialog_area_exited(area: Area2D) -> void:
	if area is DialogueTrigger:
		if area.get_parent() is Object_: interactive_obj = null
		else: dialogue_trigger = null


func _on_hit_body_entered(body: Node2D) -> void:
	if body as BaseEnemic:
		(body as BaseEnemic).hurt()


func _on_button_detected_area_entered(area: Area2D) -> void:
	if area.get_parent() as Switch:
		area.get_parent().hurt()


##---------------------------------SKILLS--------------------------------------


func sword() -> void:
	state_machine.on_child_transition("sword_attack")


func roll() -> void:
	state_machine.on_child_transition("roll")


func eye_of_horus() -> void:
	var te: Tween = create_tween()
	var eye_horus: Sprite2D = $eye_of_horus/sprite
	is_eye_horus_enable = !is_eye_horus_enable
	te.tween_property(eye_horus, "texture:fill_to", \
		Vector2(1.0, 0.0) if is_eye_horus_enable else Vector2(0.5, 0.49), 2.0)


##-----------------------------------------------------------------------


func hammer() -> void:
	state_machine.on_child_transition("hammer_attack")
	print("hammer")


func luminous_necklace() -> void:
	print("luminous_necklace")


func anubiss_shadow_bracelet(on: bool = !anubiss_bracelet_on) -> void:
	anubiss_bracelet_on = on
	anubiss_bracelet.emit(on)
	var color:Color =  Color(0.0, 0.0, 0.0, 0.565) if on else Color(1.0, 1.0, 1.0, 1.0)
	var tw:Tween = create_tween()
	tw.tween_property(self, "modulate", color, 1.0)


##-----------------------------------------------------------------------


func bug_transform() -> void:
	print("bug_transform")


func dash() -> void:
	state_machine.on_child_transition("dash")
	print("dash")


func spirit_red_charter() -> void:
	print("spirit_red_charter")


##-----------------------------------------------------------------------


func spirit_blue_charter() -> void:
	print("spirit_blue_charter")


func necklace_of_light() -> void:
	state_machine.on_child_transition("necklace_of_light")
	print("necklace_of_light")
