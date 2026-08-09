class_name Entity extends CharacterBody2D

# --- Señales ---
signal is_dead()

# --- Parámetros de Movimiento ---
@export_group("Movement Parameters")
@export var speed: float = 200.0
@export var knockback_force: float = 250.0

# --- Estadísticas de Combate ---
@export_group("Combat Stats")
@export var damage: float = 20.0
@export var max_live: float = 100.0:
	set(val):
		max_live = val
		current_live = max_live

# --- Componentes y Nodos ---
@export_group("Visuals & Audio")
@export var sprite_node: Sprite2D
@export var ray: RayCast2D
@export var hit_box: Area2D
@export var audio_player: AudioStreamPlayer2D
@export var hit_sfx: AudioStream

# --- Variables de Estado Interno ---
var current_live: float = 0.0:
	set(val):
		current_live = clampf(val, 0.0, max_live)

var current_direction: Vector2 = Vector2.DOWN
var old_direction: Vector2 = Vector2.DOWN
var knockback_velocity: Vector2 = Vector2.ZERO

@onready var state_machine: AnimationStateMachine = get_node_or_null("animation_state_machine")


func _ready() -> void:
	current_live = max_live
	appearance()


## Actualiza la orientación del RayCast según la dirección actual del personaje.
func update_direction(new_direction: Vector2) -> void:
	if new_direction == Vector2.ZERO:
		return

	current_direction = new_direction.normalized()
	old_direction = current_direction

	if ray:
		ray.target_position = current_direction * 50.0


## Calcula y aplica el vector de empuje inicial en base a la posición del atacante.
func apply_knockback(attacker_pos: Vector2) -> void:
	var push_direction: Vector2 = (global_position - attacker_pos).normalized()
	knockback_velocity = push_direction * knockback_force


## Reduce la vida de la entidad, activa el efecto visual de daño y calcula el empuje si aplica.
func hurt(damage_: float, attacker_pos: Vector2 = Vector2.ZERO) -> void:
	current_live -= damage_
	hurt_post(damage)

	animation_effect()
	play_sound(hit_sfx, -2.0, randf_range(0.9, 1.1))

	if attacker_pos != Vector2.ZERO:
		apply_knockback(attacker_pos)

	if current_live <= 0.0:
		dead()


func hurt_post(_damage: float) -> void:
	pass


## Genera un efecto visual de parpadeo rojo rápido mediante un Tween al recibir daño.
func animation_effect() -> void:
	if not sprite_node:
		return

	var tween: Tween = create_tween()
	tween.tween_property(sprite_node, "modulate", Color(5, 0.5, 0.5, 1.0), 0.1)
	tween.tween_property(sprite_node, "modulate", Color.WHITE, 0.1)


## Configuración estética inicial o de renderizado para la entidad.
func appearance() -> void:
	if sprite_node:
		sprite_node.use_parent_material = false


## Emite la señal de muerte y remueve la entidad de la escena.
func dead() -> void:
	is_dead.emit()
	queue_free()


## Reproduce un recurso de audio controlando volumen (0 a 100), tono y si debe interrumpir sonidos activos.
func play_sound(stream: AudioStream, volume_percent: float = 100.0, pitch_scale: float = 1.0, restart: bool = true) -> void:
	if not audio_player or not stream:
		return

	if audio_player.playing and audio_player.stream == stream and not restart:
		return

	var linear_volume: float = clampf(volume_percent / 100.0, 0.0, 1.0)

	audio_player.stream = stream

	audio_player.volume_db = linear_to_db(linear_volume)
	audio_player.pitch_scale = pitch_scale
	audio_player.play()
