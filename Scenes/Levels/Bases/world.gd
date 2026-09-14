class_name World extends Node2D

@onready var vortex: Vortex = $vortex_transition
@onready var level_container: Node2D = %LevelContainer
@onready var hud: Control = $CanvasLayer/HUD
@onready var pause: Pause = $CanvasLayer/Pause
@onready var inventory: Inventory = $CanvasLayer/Inventory


func _ready() -> void:
	SceneLoader.world = self

	pause.exit.connect(func()->void:
		await vortex.transition_in()
		get_tree().change_scene_to_file("res://Scenes/menus/menu_container.tscn")
	)

	#region para desarrollo
	if not Global.current_slot:
		Global.current_slot = SaveManager.available_slots[0]
	#endregion

	var section: PackedScene = load(Global.data.current_level.section)
	level_container.add_child(section.instantiate())


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_pause"):
		pause._show()
	if event.is_action_pressed(&"ui_inventory"):
		inventory._show()
