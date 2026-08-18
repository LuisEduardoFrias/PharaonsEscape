extends Panel


@export var slot: Slot = null:
	set(val):
		slot = val
		$VBoxContainer/time1.text = "time: %s" % val.time_gaming
		$VBoxContainer/live1.text = "live: %d" % val.current_live
		$VBoxContainer/bug1.text = "bug: %d" % val.bugs
		$VBoxContainer/zone1.text = "zone: %s" % val.level_name


func _on_enter_1_pressed() -> void:
	Global.data = SaveManager.select_and_load_slot(slot)
	Global.current_slot = slot
	get_tree().change_scene_to_file("res://Scenes/Levels/Bases/world.tscn")


func delete() -> void:
	SaveManager.delete_slot_game(slot.slot_id)
