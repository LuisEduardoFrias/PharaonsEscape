class_name Player extends Entity

@onready var shadow: Sprite2D = $shadow
@onready var floor_detected: Area2D = $floor_detected #area para detectar cosas en el suelo
@onready var shadow2: LightOccluder2D = $LightOccluder2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var eye_horus: EyeHorus = $eye_of_horus
@onready var hit: Area2D = $hit
@onready var question: Label = $sprite/question

@export_group("Visuals & Audio")
@export var wark_sfx: AudioStream
@export var jump_sfx: AudioStream
@export var sword_attack_sfx: AudioStream
@export var hammer_attack_sfx: AudioStream


signal is_static_state(value: bool)
signal tile_hit_respawnd
signal fall

var wall_gap: WallGapRoll = null
var interactive_object: Variant = null
var spawner_point: Vector2 = Vector2.INF
var is_in_platform: bool = false #verifica si no está en una plataforma el móvil
var is_jumping: bool = false # Para validar si está en faltando
var is_eye_horus_enable: bool = false # Verifica si está activada la habilidad del ojo de horus
var is_control_off: bool = false
var side_scroller: Node = null
var target_dir_ray: Vector2 = Vector2(13.0, 8.0)
var in_bridge: bool = false: # verifica que estén encima de un puente
	set(val):
		floor_detected.monitoring = !val
		in_bridge = val


func _ready() -> void:
	super()
	question.visible = false
	floor_detected.body_entered.connect(_floor_detected_body_entered)
	side_scroller = get_node_or_null(^"side_scroller")
	if side_scroller:
		shadow.visible = false
		collision.shape.radius = 3.0


func _physics_process(delta: float) -> void:
	if side_scroller: # composición para vista lateral
		side_scroller._on_physics_process(delta, self)
		return

	if ! is_control_off:
		var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

		if direction.length() < 0.5:
			direction = Vector2.ZERO

		current_direction = direction
		if direction != Vector2.ZERO:
			ray.target_position = (direction * target_dir_ray)

		if direction != Vector2.ZERO:
			old_direction = direction.normalized()
			velocity = old_direction * speed
		else:
			velocity = Vector2.ZERO

		if old_direction.x > 0:
			sprite_node.flip_h = true
			hit.scale = Vector2(-1.0, 1.0)
		else:
			sprite_node.flip_h = false
			hit.scale = Vector2(1.0, 1.0)

		move_and_slide()


#Detiene todas las entradas al player
func _input_physics_off(val) -> void:
	is_control_off = val
	set_physics_process(!val)
	set_process_input(!val)
	current_direction = Vector2.ZERO
	is_static_state.emit(val)

	if val:
		velocity = Vector2.ZERO
		move_and_slide()


# Método para cinematica de movimientos en Top-Down
func _move_to(dir: Vector2, move_time: float) -> void:
	_input_physics_off(true)
	current_direction = dir
	old_direction = dir

	if not is_node_ready():
		await ready

	# Bucle de emulación de movimiento por tiempo fijo a velocidad constante
	var time: float = 0.0

	while time < move_time:

		var delta: float = get_physics_process_delta_time()

		if dir.x > 0: sprite_node.flip_h = true
		else: sprite_node.flip_h = false

		velocity = current_direction * speed

		if not is_inside_tree(): break
		move_and_slide()

		if state_machine.animation_name != "walk":
			state_machine._cinematic(AnimationStateMachine.States.WALK)
			#state_machine._on_child_transition(AnimationStateMachine.States.WALK)

		time += delta

		if not get_tree(): break

		await get_tree().physics_frame


	velocity = Vector2.ZERO
	move_and_slide()

	current_direction = Vector2.ZERO


func move_to_kinematic_point(destination_point: Vector2):
	Engine.time_scale = 0.3
	state_machine.playback.travel("walk")

	var distance = global_position.distance_to(destination_point)

	var travel_time = distance / max(speed/2, 1.0)

	var tween = create_tween()
	tween.tween_property(self, "global_position", destination_point, travel_time).set_trans(Tween.TRANS_LINEAR)
	await tween.finished
	current_direction = Vector2.ZERO
	velocity = Vector2.ZERO
	move_and_slide()

	Engine.time_scale = 1.0


## Método que hace que el Player sea intermitente por un periodo de tiempo
func intermittency(duration: float = 1.0, callback: Callable = Callable()) -> void:
	var tw: Tween = create_tween().set_loops()

	tw.tween_property(self, "modulate:a", 0.0, 0.1)
	tw.tween_property(self, "modulate:a", 1.0, 0.1)

	await get_tree().create_timer(duration).timeout

	tw.kill()
	modulate.a = 1.0
	if callback.is_valid(): callback.call_deferred()


## Método para interacción con el piso
func _floor_detected_body_entered(body: Node2D) -> void:
	if body is TileMapLayer and not is_in_platform:
		var tilemap_layer := body as TileMapLayer

		# Punto de contacto corregido hacia el interior del detector
		var detector_pos: Vector2 = floor_detected.global_position
		var velocity_dir: Vector2 = velocity.normalized() if "velocity" in self and velocity != Vector2.ZERO else Vector2.ZERO

		# Proyección de 2 a 4 píxeles en la dirección de entrada para asegurar la celda correcta
		var evaluation_point: Vector2 = detector_pos + (velocity_dir * 4.0)

		var local_pos: Vector2 = tilemap_layer.to_local(evaluation_point)
		var cell_coords: Vector2i = tilemap_layer.local_to_map(local_pos)

		var tile_center_local: Vector2 = tilemap_layer.map_to_local(cell_coords)
		var tile_center_global: Vector2 = tilemap_layer.to_global(tile_center_local)

		_tile_hit(body, tile_center_global)



func _move_platform(body: AnimatableBody2D) -> void:
	position.move_toward(body.position, 0.5)


## Método que silve para interacion con Tiles que hacen daño
func _tile_hit(_body: TileMapLayer, tile_center_global: Vector2) -> void:
	_input_physics_off(true)
	var tw: Tween = create_tween()
	tw.tween_property(self, ^"position", tile_center_global, 1.0)
	state_machine._on_child_transition(AnimationStateMachine.States.FALL)
	await state_machine.animation_finished
	fall.emit()

	if spawner_point != Vector2.INF:
		await Util.timerout(0.5)
		position = spawner_point
		intermittency()
		state_machine._on_child_transition(AnimationStateMachine.States.IDLE)
		await Util.timerout(0.5)
		tile_hit_respawnd.emit()
		_input_physics_off(false)


func show_quetion(is_show: bool) -> void:
	if is_show: $sprite/question/AnimationPlayer.play(&"play")
	else: $sprite/question/AnimationPlayer.stop()
	question.visible = is_show


func input(state: StateBase, event: InputEvent) -> void:
	if is_control_off:
		return
	var skill: SkillsData.SkillsType = SkillsData.SkillsType.NONE

	if event.is_action_pressed(&"ui_action_1"):
		if interactive_object:
			state.change_state.emit(AnimationStateMachine.States.INTERACT, {})
		elif not is_jumping:
			state.change_state.emit(AnimationStateMachine.States.JUMP, {})
		return
	if event.is_action_pressed(&"ui_action_2"):
		skill = Global.player_data.equipped_skills[0]
	if event.is_action_pressed(&"ui_action_3"):
		skill = Global.player_data.equipped_skills[1]
	if event.is_action_pressed(&"ui_action_4"):
		skill = Global.player_data.equipped_skills[2]

	if skill != SkillsData.SkillsType.NONE:
			action_btn(skill, state)


func action_btn(skill_type: SkillsData.SkillsType, state: StateBase) -> void:
	match skill_type:
		SkillsData.SkillsType.SWORD:
			state.change_state.emit(AnimationStateMachine.States.SWORD_ATTACK, {})
		SkillsData.SkillsType.ROLL:
			state.change_state.emit(AnimationStateMachine.States.ROLL, {})
		SkillsData.SkillsType.EYE_OF_HORUS:
			eye_horus._enable_eje_horus()
