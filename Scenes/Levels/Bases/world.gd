class_name World extends Node2D

@onready var level_container: Node2D = %LevelContainer
@onready var hud: Control = $CanvasLayer/HUD


func _ready() -> void:
	SceneLoader.world = self#get_tree().get_first_node_in_group("World")

	#region para desarrollo
	if not Global.current_slot:
		Global.current_slot = SaveManager.available_slots[0]
	#endregion

	var section: PackedScene = load(Global.data.current_level.section)
	level_container.add_child(section.instantiate())
