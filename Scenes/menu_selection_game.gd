extends Control

var panel:PackedScene = load("res://Scenes/game_panel.tscn")


func _ready() -> void:
	for slot:Slot in SaveManager.available_slots:
		var inst = panel.instantiate()
		inst.slot = slot
		$Panel/container.add_child(inst)


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
