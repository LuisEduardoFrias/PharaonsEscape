class_name EnemyBase extends CharacterBody2D

# --- Enum de Patrullaje ---
enum PatrolDirection {
	HORIZONTAL,
	VERTICAL,
	DIAGONAL_LEFT,
	DIAGONAL_RIGHT
}

# --- Señales ---
signal is_dead()
signal detect_the_player_body_entered(body: Player)
signal detect_the_player_body_exited()
signal attack_the_player_body_entered(body: Player)
signal attack_the_player_body_exited()

# --- Nodos Internos ---
@onready var state_machine: AnimationEnemyStateMachine = get_node_or_null("animation_state_machine")
@onready var anim: AnimationPlayer = $Anim
@onready var sprite: Sprite2D = $sprite
@onready var hit_box: Area2D = $hit
@onready var pit_detector: Area2D = $pit_detector
@onready var audio_play: AudioStreamPlayer2D = $audio_play

# --- Parámetros de Movimiento y Patrulla ---
@export_group("Movement Parameters")
@export var speed: float = 200.0
@export var knockback_force: float = 250.0

@export_group("Patrol Settings")
@export var patrol_direction_type: PatrolDirection = PatrolDirection.HORIZONTAL
@export var patrol_distance: float = 150.0
@export var idle_wait_time: float = 2.0

# --- Estadísticas de Combate ---
@export_group("Combat Stats")
@export var damage: int = 1
@export var max_live: int = 100:
	set(val):
		max_live = val
		current_live = max_live

# --- Recursos de Audio ---
@export_group("Audio Resources")
@export var attack_sfx: AudioStream
@export var hurt_sfx: AudioStream
@export var walk_sfx: AudioStream

# --- Variables de Estado Interno ---
var current_live: int = 0:
	set(val):
		current_live = clampi(val, 0, max_live)

var current_direction: Vector2 = Vector2.RIGHT
var old_direction: Vector2 = Vector2.RIGHT
var knockback_velocity: Vector2 = Vector2.ZERO
var target_player: Player = null

# Variables de control de Patrulla y Estado
var start_patrol_position: Vector2 = Vector2.ZERO
var patrol_target_position: Vector2 = Vector2.ZERO
var moving_to_target: bool = true
var is_waiting: bool = false
var is_player_in_attack_range: bool = false
var is_falling: bool = false


func _ready() -> void:
	if sprite and sprite.material:
		sprite.material = sprite.material.duplicate()

	current_live = max_live
	start_patrol_position = global_position
	calculate_patrol_target()
	appearance()


func _physics_process(delta: float) -> void:
	if current_live <= 0 or is_falling:
		return

	if knockback_velocity.length() > 10.0:
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 500.0 * delta)
		move_and_slide()
		return

	if target_player != null:
		handle_chase()
	else:
		handle_patrol()

	move_and_slide()

	if is_on_wall() and target_player == null and not is_waiting:
		start_idle_wait()


## Calcula el punto final de patrulla basado en el Enum seleccionado.
func calculate_patrol_target() -> void:
	var dir_vector: Vector2 = Vector2.ZERO

	match patrol_direction_type:
		PatrolDirection.HORIZONTAL:
			dir_vector = Vector2.RIGHT
		PatrolDirection.VERTICAL:
			dir_vector = Vector2.DOWN
		PatrolDirection.DIAGONAL_LEFT:
			dir_vector = Vector2(1, 1).normalized()
		PatrolDirection.DIAGONAL_RIGHT:
			dir_vector = Vector2(-1, 1).normalized()

	patrol_target_position = start_patrol_position + (dir_vector * patrol_distance)


## Maneja la patrulla cíclica ida y vuelta.
func handle_patrol() -> void:
	if is_waiting:
		velocity = Vector2.ZERO
		return

	var current_destination: Vector2 = patrol_target_position if moving_to_target else start_patrol_position
	var distance_to_dest: float = global_position.distance_to(current_destination)

	if distance_to_dest <= 5.0:
		start_idle_wait()
		return

	var move_dir: Vector2 = global_position.direction_to(current_destination)
	velocity = move_dir * speed
	update_direction(move_dir)
	play_sound(walk_sfx, 80.0, 1.0, false)

	if state_machine:
		state_machine._on_child_transition(AnimationEnemyStateMachine.States.WALK)


## Avanza de forma continua hacia el jugador hasta pegársele o atacar.
func handle_chase() -> void:
	if is_player_in_attack_range:
		velocity = Vector2.ZERO
		play_sound(attack_sfx)
		if state_machine:
			state_machine._on_child_transition(AnimationEnemyStateMachine.States.ATTACK1)
		return

	# Fuerza el movimiento continuo directo a la posición del jugador sin detenerse
	var dir_to_player: Vector2 = (target_player.global_position - global_position).normalized()
	velocity = dir_to_player * speed
	update_direction(dir_to_player)
	play_sound(walk_sfx, 80.0, 1.0, false)

	if state_machine:
		state_machine._on_child_transition(AnimationEnemyStateMachine.States.WALK)


## Pausa al enemigo durante los segundos configurados y cambia el sentido de la patrulla.
func start_idle_wait() -> void:
	is_waiting = true
	velocity = Vector2.ZERO

	if state_machine:
		state_machine._on_child_transition(AnimationEnemyStateMachine.States.IDLE)

	moving_to_target = !moving_to_target

	await get_tree().create_timer(idle_wait_time).timeout
	is_waiting = false


## Actualiza la dirección y voltea visualmente el sprite según el movimiento.
func update_direction(new_direction: Vector2) -> void:
	if new_direction == Vector2.ZERO:
		return

	current_direction = new_direction.normalized()
	old_direction = current_direction

	if state_machine:
		state_machine.animation_direction(current_direction)


## Aplica el retroceso al recibir un golpe.
func apply_knockback(attacker_pos: Vector2) -> void:
	var push_direction: Vector2 = (global_position - attacker_pos).normalized()
	knockback_velocity = push_direction * knockback_force

	if state_machine:
		state_machine._on_child_transition(AnimationEnemyStateMachine.States.HURT)


## Procesa el daño recibido.
func hurt(damage_: int, attacker_pos: Vector2 = Vector2.ZERO) -> void:
	if is_falling:
		return

	current_live -= damage_
	hurt_post(damage_)

	animation_effect()
	play_sound(hurt_sfx, 100.0, randf_range(0.9, 1.1))

	if attacker_pos != Vector2.ZERO:
		apply_knockback(attacker_pos)

	if current_live <= 0:
		dead()


func hurt_post(_damage: int) -> void:
	pass


## Efecto visual de parpadeo de daño.
func animation_effect() -> void:
	if not sprite:
		return

	var tween: Tween = create_tween()
	tween.tween_property(sprite, "modulate", Color(5, 0.5, 0.5, 1.0), 0.1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)


func appearance() -> void:
	if sprite:
		sprite.use_parent_material = false


## Emite la señal de muerte y elimina la instancia.
func dead() -> void:
	if state_machine:
		state_machine._on_child_transition(AnimationEnemyStateMachine.States.DEATH)
	is_dead.emit()
	queue_free()


## Reproducción centralizada de sonido.
func play_sound(stream: AudioStream, volume_percent: float = 100.0, pitch_scale: float = 1.0, restart: bool = true) -> void:
	if not audio_play or not stream:
		return

	if audio_play.playing and audio_play.stream == stream and not restart:
		return

	var linear_volume: float = clampf(volume_percent / 100.0, 0.0, 1.0)
	audio_play.stream = stream
	audio_play.volume_db = linear_to_db(linear_volume)
	audio_play.pitch_scale = pitch_scale
	audio_play.play()


# --- Lógica del Precipicio (Pit Detector) ---

func _on_pit_detector_area_entered(_area: Area2D) -> void:
	is_falling = true
	velocity = Vector2.ZERO

	if has_node("collision"):
		$collision.set_deferred("disabled", true)

	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.4)
	tween.tween_callback(queue_free)


func _on_pit_detector_body_entered(_body: Node2D) -> void:
	pass


# --- Conexiones de Señales ---

func _on_detect_the_player_body_entered(body: Node2D) -> void:
	if body is Player:
		target_player = body as Player
		detect_the_player_body_entered.emit(body)


func _on_detect_the_player_body_exited(body: Node2D) -> void:
	if body == target_player:
		target_player = null
		detect_the_player_body_exited.emit()


func _on_attack_the_player_body_entered(body: Node2D) -> void:
	if body is Player:
		is_player_in_attack_range = true
		attack_the_player_body_entered.emit(body)


func _on_attack_the_player_body_exited(body: Node2D) -> void:
	if body is Player:
		is_player_in_attack_range = false
		attack_the_player_body_exited.emit()


func _on_hit_body_entered(body: Node2D) -> void:
	if body is Player:
		body.hurt(damage)
