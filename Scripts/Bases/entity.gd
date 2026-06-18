class_name Entity extends CharacterBody2D

@export_group("Movement Parameters")
@export var speed: float = 200.0

@export_group("Visuals & Audio")
@export var sprite_node: Sprite2D
@export var ray: RayCast2D
@export var animation_tree: AnimationTree
@export var audio_player: AudioStreamPlayer2D

# Variables de estado interno
var current_direction: Vector2 = Vector2.DOWN
var old_direction: Vector2 = Vector2.DOWN
var playback: AnimationNodeStateMachinePlayback

# Referencia a la máquina de estados
@onready var state_machine: StateMachine = get_node_or_null("StateMachine")


func _ready() -> void:
	playback = animation_tree["parameters/playback"]

	assert(animation_tree != null, "[Error Crítico]: El nodo AnimationTree no ha sido asignado en el Inspector de: " + name)
	assert(playback != null, "[Error Crítico]: No se pudo obtener el 'parameters/playback' del AnimationTree en: " + name)



## Reproduce un sonido con control opcional de volumen, tono y reinicio.
## @param stream: El recurso de audio a reproducir.
## @param volume_db: Ajuste de volumen (0.0 es el original, -10.0 es más bajo).
## @param pitch_scale: Velocidad/Tono del audio (1.0 es normal).
## @param restart: Si es falso y el sonido ya suena, no lo interrumpe.
func play_sound(stream: AudioStream, volume_db: float = 0.0, pitch_scale: float = 1.0, restart: bool = true) -> void:
	if !audio_player or !stream:
		return

	# Si ya se está reproduciendo este mismo sonido y no queremos reiniciar, salimos
	if audio_player.playing and audio_player.stream == stream and not restart:
		return

	audio_player.stream = stream
	audio_player.volume_db = volume_db
	audio_player.pitch_scale = pitch_scale
	audio_player.play()
