class_name FadeInOut extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
var mat: ShaderMaterial


func _ready() -> void:
	mat = color_rect.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("progress", 1.0)


func change_scene(callback: Callable, duration: float = 1.0) -> Signal:
	var tween_in = create_tween()
	tween_in.tween_property(mat, "shader_parameter/progress", 1.0, duration)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)

	await tween_in.finished
	callback.call()
	await get_tree().create_timer(0.3).timeout

	var tween_out = create_tween()
	tween_out.tween_property(mat, "shader_parameter/progress", 0.0, duration)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
	return tween_out.finished


func fade_in(duration: float = 1.0) -> void:
	var tween_out = create_tween()
	tween_out.tween_property(mat, "shader_parameter/progress", 0.0, duration)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
