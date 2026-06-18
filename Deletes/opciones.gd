extends Control

enum Language {
	ES = 0,
	EN = 1,
	FR = 2,
}

func _ready() -> void:
	change_language($VBoxContainer/OptionButton.selected)

func _on_button_4_pressed() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")


func _on_option_button_item_selected(index: int) -> void:
	change_language(index)


func change_language(index: int) -> void:
	var code: String = Language.keys()[index]

	if !code:
		push_warning("Índice de idioma no reconocido: ", index)
		code = ProjectSettings.get_setting("internationalization/locale/fallback")

	TranslationServer.set_locale(code.to_lower())
