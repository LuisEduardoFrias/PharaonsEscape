class_name World extends Node2D

@onready var level_container: Node2D = %LevelContainer
@onready var hud: Control = $CanvasLayer/HUD


func _ready() -> void:
	SceneLoader.world = get_tree().get_first_node_in_group("World")

	var section: PackedScene = load(Global.data.current_level.section)
	level_container.add_child(section.instantiate())
