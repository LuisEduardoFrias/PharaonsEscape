extends Control


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://opciones.tscn")


func _on_button_3_pressed() -> void:
	get_tree().change_scene_to_file("res://extras.tscn")


func _on_button_4_pressed() -> void:
	get_tree().quit()
