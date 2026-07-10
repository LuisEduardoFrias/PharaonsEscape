@tool class_name Escalator extends StaticBody2D

@export_enum("TYPE_1", "TYPE_2") var type: String = "TYPE_1":
	set(val):
		type = val
		if not is_node_ready(): await ready
		anim.speed_scale = 1.0 if opening else 0.0
		anim.current_animation = val.to_lower()

@export var opening: bool = false:
	set(val):
		opening = val
		if not is_node_ready(): await ready
		anim.speed_scale = 1.0 if val else 0.0
		anim.current_animation = type.to_lower()
		if val: $CollisionShape2D2.shape.size = Vector2(22.0, 64)

@onready var anim: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	var col2: CollisionShape2D = $CollisionShape2D2
	col2.shape = col2.shape.duplicate()


func _open() -> void:
	anim.speed_scale = 1.0
	anim.play(type.to_lower())
	$CollisionShape2D2.shape.size = Vector2(22.0, 64)



func _close() -> void:
	anim.speed_scale = 1.0
	anim.play_backwards(type.to_lower())
