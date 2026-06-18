extends ColorRect

@export var player: Player


func _process(_delta: float) -> void:
	var posicion_pantalla: Vector2 = player.get_global_transform_with_canvas().origin
	var mat = material as ShaderMaterial
	mat.set_shader_parameter("player_uv", posicion_pantalla)


func transition_in(time: float = 1.0) -> void:
	if not is_node_ready(): await ready

	var tween = create_tween()
	tween.tween_property(material, "shader_parameter/fade_progress", 1.0, time).from(0.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func transition_out(time: float = 0.5) -> void:
	var tween = create_tween()
	tween.tween_property(material, "shader_parameter/fade_progress", 0.0, time).from(1.0)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
