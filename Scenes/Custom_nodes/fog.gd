extends ColorRect

@onready var camera: CustomCamera

func _process(_delta) -> void:
	if not camera:
		camera = get_viewport().get_camera_2d()

	if camera:
		material.set_shader_parameter("camera_position", camera.global_position)
