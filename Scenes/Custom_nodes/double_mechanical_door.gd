@tool class_name DoubleMechanicalDoor extends StaticBody2D

@onready var anim: AnimationPlayer = $AnimationPlayer

@export var opening: bool = false:
	set(val):
		opening = val
		if not is_node_ready(): await ready
		if val: anim.play(&"open")
		else: anim.play_backwards(&"open")


func _open() -> void:
	anim.play(&"open")


func _close() -> void:
	anim.play_backwards(&"open")
