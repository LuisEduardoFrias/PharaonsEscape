'''
@tool
extends Control

@onready var file_path_label: Label = %FilePathLabel
@onready var save_button: Button = %SaveButton
@onready var text_editor: CodeEdit = %TextEditor

var current_file_path: String = ""

func _ready() -> void:
	if save_button and not save_button.pressed.is_connected(save_current_file):
		save_button.pressed.connect(save_current_file)

	if text_editor:
		text_editor.gutters_draw_line_numbers = true
		# Sintaxis correcta de Godot 4 para CodeEdit/TextEdit:
		text_editor.wrap_mode = TextEdit.LineWrappingMode.LINE_WRAPPING_NONE

func open_file(path: String) -> void:
	if not FileAccess.file_exists(path):
		return

	current_file_path = path

	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()

		if text_editor:
			text_editor.text = content

		if file_path_label:
			file_path_label.text = path

func save_current_file() -> void:
	if current_file_path.is_empty():
		return

	var file = FileAccess.open(current_file_path, FileAccess.WRITE)
	if file:
		file.store_string(text_editor.text)
		file.close()
		print("Archivo guardado con éxito: ", current_file_path)

func close_file_if_open(path: String) -> void:
	if current_file_path == path:
		current_file_path = ""
		if file_path_label:
			file_path_label.text = " No hay archivo abierto"
		if text_editor:
			text_editor.text = ""
'''

@tool
extends Control

@onready var file_path_label: Label = %FilePathLabel
@onready var save_button: Button = %SaveButton
@onready var text_editor: CodeEdit = %TextEditor
@onready var find_input: TextEdit = %Find
@onready var find_button: Button = %FindButton

var current_file_path: String = ""

func _ready() -> void:
	if save_button and not save_button.pressed.is_connected(save_current_file):
		save_button.pressed.connect(save_current_file)

	if find_button and not find_button.pressed.is_connected(_on_find_button_pressed):
		find_button.pressed.connect(_on_find_button_pressed)

	if text_editor:
		text_editor.gutters_draw_line_numbers = true
		text_editor.wrap_mode = TextEdit.LineWrappingMode.LINE_WRAPPING_NONE

func open_file(path: String) -> void:
	if not FileAccess.file_exists(path):
		return

	current_file_path = path

	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()

		if text_editor:
			text_editor.text = content

		if file_path_label:
			file_path_label.text = path

func save_current_file() -> void:
	if current_file_path.is_empty():
		return

	var file = FileAccess.open(current_file_path, FileAccess.WRITE)
	if file:
		file.store_string(text_editor.text)
		file.close()
		print("Archivo guardado con éxito: ", current_file_path)

func close_file_if_open(path: String) -> void:
	if current_file_path == path:
		current_file_path = ""
		if file_path_label:
			file_path_label.text = " No hay archivo abierto"
		if text_editor:
			text_editor.text = ""

func _on_find_button_pressed() -> void:
	if not text_editor or not find_input:
		return

	var query: String = find_input.text.strip_edges()
	if query.is_empty():
		return

	var current_line: int = text_editor.get_caret_line()
	var current_col: int = text_editor.get_caret_column()

	var result = text_editor.search(query, 0, current_line, current_col)

	if result.x == -1:
		result = text_editor.search(query, 0, 0, 0)

	if result.x != -1:
		var column: int = result.x
		var line: int = result.y

		text_editor.select(line, column, line, column + query.length())
		text_editor.set_caret_line(line)
		text_editor.set_caret_column(column + query.length())
		text_editor.adjust_carets_at_line(line)
