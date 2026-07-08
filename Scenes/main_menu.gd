extends Control


func _ready() -> void:
	print(SaveManager.game_settings)


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/menu_selection_game.tscn")


func _on_button_4_pressed() -> void:
	get_tree().quit()


func save_settings() -> void:
	SaveManager.save_game_settings()
