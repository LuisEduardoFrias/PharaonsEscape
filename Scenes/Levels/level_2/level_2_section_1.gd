extends SectionBase

@onready var switch_lower_level: Area2D = $area/switch_lower_level


func _on_switch_lower_level_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body is Player:
		var tw: Tween = create_tween()
		var coli: CollisionShape2D = switch_lower_level.get_child(local_shape_index)
		var color: Color = Color("Transparent") if coli.get_meta("type") == "hidden" else Color("white")
		tw.tween_property(lower_level, ^"modulate", color, 0.5)
	if local_shape_index in [4, 5]:
		lower_level.collision_enabled = local_shape_index == 4
		lower_level.z_index = 1 if local_shape_index == 4 else 2
