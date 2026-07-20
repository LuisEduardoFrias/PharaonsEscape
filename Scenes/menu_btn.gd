@tool
extends TextureButton

@export var button_text: String = "Button":
	set(value):
		button_text = value
		if is_inside_tree():
			$Label.text = value

@export var click_sound: AudioStream = load("res://Audio/audio_btn.wav")
@export var hover_sound: AudioStream = load("res://Audio/audio_btn.wav")
@onready var label_node: Label = $Label
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer


func _ready() -> void:
	label_node.text = button_text
	if not Engine.is_editor_hint():
		mouse_entered.connect(_on_mouse_entered)
		button_down.connect(_on_down)


func _on_mouse_entered() -> void:
	if hover_sound:
		audio_player.stream = hover_sound
		audio_player.volume_db = -12
		audio_player.pitch_scale = 3.0
		audio_player.play()


func _on_down() -> void:
	if click_sound:
		audio_player.stream = click_sound
		audio_player.volume_db = -5
		audio_player.pitch_scale = 1.0
		audio_player.play()
