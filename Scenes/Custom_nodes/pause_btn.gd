@tool extends TextureButton

@onready var audio: AudioStreamPlayer2D = $audio_sfx

@export var text: String = "Button":
	set(val):
		text = val
		$MarginContainer/Label.text = val


func _on_mouse_entered() -> void:
	if not disabled:
		play_sfx()


func _on_button_down() -> void:
	if not disabled:
		play_sfx()


func play_sfx() -> void:
	if audio and audio.stream:
		audio.play()
