extends Control

func _on_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$VBoxContainer/Panel/VBoxContainer/CheckButton2.button_pressed = false
		$VBoxContainer/Panel/VBoxContainer/Label.text = tr("legendary")

	elif ! $VBoxContainer/Panel/VBoxContainer/CheckButton2.button_pressed:
		$VBoxContainer/Panel/VBoxContainer/Label.text = tr("Text to change")


func _on_check_button_2_toggled(toggled_on: bool) -> void:
	if toggled_on:
		$VBoxContainer/Panel/VBoxContainer/CheckButton.button_pressed = false
		$VBoxContainer/Panel/VBoxContainer/Label.text = tr("new")

	elif ! $VBoxContainer/Panel/VBoxContainer/CheckButton.button_pressed:
		$VBoxContainer/Panel/VBoxContainer/Label.text = tr("Text to change")


func _on_button_4_pressed() -> void:
	get_tree().change_scene_to_file("res://menu.tscn")
