class_name Inventory extends Control


func _show() -> void:
	get_tree().paused = true
	Util.show_node(self, true, 0.5)


func _hidden() -> void:
	await Util.show_node(self, false, 0.5)
	get_tree().paused = false


func _on_back_pressed() -> void:
	_hidden()
