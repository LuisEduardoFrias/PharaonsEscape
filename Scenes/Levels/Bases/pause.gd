class_name Pause extends Control

signal exit

@onready var settings: TextureRect = $Panel/settings


func _show() -> void:
	get_tree().paused = true
	Util.show_node(self, true, 0.5)


func _hidden() -> void:
	await Util.show_node(self, false, 0.5)
	get_tree().paused = false


func _on_continuous_pressed() -> void:
	_hidden()


func _on_settings_pressed() -> void:
	Util.show_node(settings, true)


func _on_save_game_pressed() -> void:
	Global.save_game()


func _on_exit_game_pressed() -> void:
	get_tree().paused = false
	exit.emit()


func _on_back_control_pressed() -> void:
	Util.show_node(settings, false)
