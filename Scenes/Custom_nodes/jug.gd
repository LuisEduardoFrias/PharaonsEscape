class_name Jug extends AnimatableBody2D

var audio_move : AudioStream = preload("res://Audios/level_3/jam_move.wav")
var audio_fall : AudioStream = preload("res://Audios/level_3/jam_fall.wav")
var audio_impact : AudioStream = preload("res://Audios/level_3/jam_impact.wav")
var default_position: Vector2

signal falling(name: String)
signal reseting

@onready var audio := $audio_stream_player
@onready var pushable := $pushable
@onready var anim := $anim


func _ready() -> void:
	default_position = position

	var camera : CustomCamera = get_viewport().get_camera_2d()

	pushable.impact.connect(func () -> void:
		audio.stop()
		audio.stream = audio_impact
		audio.play()
		camera.add_trauma(0.4)
	)

	pushable.moving.connect(func () -> void:
		if !audio.playing and audio.stream != audio_move:
			audio.stream = audio_move
			audio.play()
	)


func inlaid(position_: Vector2) -> void:
	anim.play(&"inlaid")
	position = position_


func fall() -> void:
	falling.emit(name)
	audio.stop()
	audio.stream = audio_fall
	audio.play()
	anim.play("fall")
	pushable.disabled()


func reset() -> void:
	anim.play(&"default")
	reseting.emit()
	position = default_position
	pushable.disabled(false)
