class_name BossFight extends Node2D

@onready var dialog: DialogTrigger = $dialog_trigger
@onready var player: Player = $Player

@export var dialogo_final: DialogueResource

func _ready() -> void:
	dialog.data.set("player", player)
	var vortex: CanvasLayer = Util._find_vortex()
	vortex.player = player
	await vortex.transition_out()


func _on_battle_zone_battle_finished() -> void:
	pass # Replace with function body.
