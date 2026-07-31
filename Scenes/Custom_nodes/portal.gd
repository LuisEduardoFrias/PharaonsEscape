@tool extends Sprite2D

enum Type_Wall { WALL1, WALL2 }

@export var wall: Type_Wall = Type_Wall.WALL1:
	set(val):
		wall = val
		if not is_node_ready(): await ready
		frame = 210 if val == Type_Wall.WALL1 else 1
@export var effect_strength: float = 0.03:
	set(val):
		effect_strength = val
		material["shader_parameter/effect_strength"] = val


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body as Player:
		var tween = create_tween()
		tween.tween_property(material, "shader_parameter/effect_strength", 1.0, 0.3)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body as Player:
		var tween = create_tween()
		tween.tween_property(material, "shader_parameter/effect_strength", 0.0, 0.3)
