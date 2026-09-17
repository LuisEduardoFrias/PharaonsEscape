@tool
extends EditorPlugin

const EDITOR_SCREEN = preload("res://addons/text_edit/TextEditorMain.tscn")

var editor_instance: Control
var context_menu_plugin: MyContextMenuPlugin

func _enter_tree() -> void:
	# 1. Instanciar la interfaz
	editor_instance = EDITOR_SCREEN.instantiate()
	editor_instance.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	editor_instance.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	editor_instance.size_flags_vertical = Control.SIZE_EXPAND_FILL

	EditorInterface.get_editor_main_screen().add_child(editor_instance)
	_make_visible(false)

	# 2. Registrar el menú contextual oficial para el FileSystem
	context_menu_plugin = MyContextMenuPlugin.new(self)
	add_context_menu_plugin(EditorContextMenuPlugin.CONTEXT_SLOT_FILESYSTEM, context_menu_plugin)

func _exit_tree() -> void:
	if context_menu_plugin:
		remove_context_menu_plugin(context_menu_plugin)
		context_menu_plugin = null

	if editor_instance:
		editor_instance.queue_free()

func _has_main_screen() -> bool:
	return true

func _make_visible(visible: bool) -> void:
	if editor_instance:
		editor_instance.visible = visible

func _get_plugin_name() -> String:
	return "TE"

func _get_plugin_icon() -> Texture2D:
	return EditorInterface.get_base_control().get_theme_icon("TextFile", "EditorIcons")

func open_file_in_editor(path: String) -> void:
	if editor_instance and editor_instance.has_method("open_file"):
		editor_instance.open_file(path)
		EditorInterface.set_main_screen_editor("TE")


# Clase interna para manejar la opción del menú contextual en Godot 4
class MyContextMenuPlugin extends EditorContextMenuPlugin:
	var main_plugin: EditorPlugin

	func _init(p_plugin: EditorPlugin) -> void:
		main_plugin = p_plugin

	func _popup_menu(paths: PackedStringArray) -> void:
		if paths.is_empty():
			return

		var path = paths[0]
		# No mostrar si se hizo clic derecho sobre una carpeta
		if DirAccess.dir_exists_absolute(path):
			return

		add_context_menu_item("Abrir con Editor de Texto (TE)", _on_open_clicked)

	func _on_open_clicked(paths: PackedStringArray) -> void:
		if paths.size() > 0 and main_plugin:
			main_plugin.open_file_in_editor(paths[0])
