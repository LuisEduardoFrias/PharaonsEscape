extends Node2D
class_name World

@onready var level_container: Node2D = $CanvasLayer2/SubViewportContainer/SubViewport/LevelContainer
@onready var hud: Control = $CanvasLayer/HUD


func _ready() -> void:
	pass
