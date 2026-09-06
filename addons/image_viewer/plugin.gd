@tool
extends EditorPlugin

const VIEWER_SCENE = preload("res://addons/image_viewer/image_viewer.tscn")
var viewer_instance: Control
var current_texture: Texture2D = null


func _enter_tree() -> void:
	viewer_instance = VIEWER_SCENE.instantiate()
	viewer_instance.name = "IV"

	viewer_instance.set_anchors_preset(Control.PRESET_FULL_RECT)
	EditorInterface.get_editor_main_screen().add_child(viewer_instance)
	_make_visible(false)

	var inspector = EditorInterface.get_inspector()
	if inspector and not inspector.edited_object_changed.is_connected(_on_inspector_object_changed):
		inspector.edited_object_changed.connect(_on_inspector_object_changed)


func _exit_tree() -> void:
	var inspector = EditorInterface.get_inspector()
	if inspector and inspector.edited_object_changed.is_connected(_on_inspector_object_changed):
		inspector.edited_object_changed.disconnect(_on_inspector_object_changed)

	if viewer_instance:
		viewer_instance.queue_free()


func _has_main_screen() -> bool:
	return true


func _make_visible(visible: bool) -> void:
	if viewer_instance:
		viewer_instance.visible = visible
		if visible:
			viewer_instance.set_anchors_preset(Control.PRESET_FULL_RECT)


func _get_plugin_name() -> String:
	return "IV"


func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_base_control().get_theme_icon("Image", "EditorIcons")


func _on_inspector_object_changed() -> void:
	var obj = EditorInterface.get_inspector().get_edited_object()

	if obj is Texture2D:
		if obj == current_texture:
			return

		current_texture = obj

		if viewer_instance and viewer_instance.has_method("set_image"):
			viewer_instance.set_image(current_texture)

		EditorInterface.set_main_screen_editor("IV")
