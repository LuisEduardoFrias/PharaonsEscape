@tool extends Node2D

@onready var collision: = $animatable_body/collision

enum Types { TYPE_1, TYPE_2 }

@export var type: Types = Types.TYPE_1:
	set(val):
		type = val
		if not is_node_ready(): await ready
		animation = &"open_close_type_1" if val == Types.TYPE_1 else &"open_close_type_2"
		$animated_sprite.animation = animation

var animation : StringName = &"open_close_type_1"

@export var owner_name: LevelsData.Levels = LevelsData.Levels.LEVEL1

func _ready() -> void:
	if Global.check_door(owner_name, name) : _open()
	#TODO verificar en global si esta puerta está registrada por su nombre para abrirla o no


func _open() -> void:
	collision.shape.set_deferred("size", Vector2(12.0, 57.0))
	collision.set_deferred("position", Vector2(6.0, 28.5))
	$animated_sprite.play(animation)


func _close() -> void:
	collision.shape.set_deferred("size", Vector2(51.0, 57.0))
	collision.set_deferred("position", Vector2(25.5, 28.5))
	$animated_sprite.play_backwards(animation)
