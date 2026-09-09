class_name Presentation extends Control

@export var Scene: PackedScene

func _ready() -> void:
	var video: VideoStreamPlayer = $VideoStreamPlayer
	var anim: AnimationPlayer = $TextureRect/AnimationPlayer
	var texture : TextureRect = $TextureRect

	anim.animation_finished.connect(func (_anim_name: String) -> void :
		var tween: Tween = _get_tween()
		tween.tween_property(texture, "modulate", Color("ffffff00"), 1.0)
		tween.tween_callback(func () -> void: get_tree().change_scene_to_packed(Scene))
	)

	video.finished.connect(func () -> void :
		var tween: Tween = _get_tween()
		tween.tween_property(video, "modulate", Color("ffffff00"), 1.0)
		tween.tween_callback(func () -> void: anim.play("show-godot"))
		tween.tween_property(texture, "modulate", Color("ffffffff"), 2.0)
		)


func _get_tween() -> Tween:
	var tween: Tween = get_tree().create_tween()
	tween.set_trans(Tween.TRANS_LINEAR,)
	tween.set_ease( Tween.EASE_OUT_IN)

	return tween
