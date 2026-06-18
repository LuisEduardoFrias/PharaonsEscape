extends Area2D

@export var is_down: bool = true

var tw: Tween = null

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		var lower: TileMapLayer = (owner as SectionBase).lower_level
		var back: TileMapLayer = (owner as SectionBase).background
		var middle: TileMapLayer = (owner as SectionBase).middleground
		var fore: TileMapLayer = (owner as SectionBase).foreground

		lower.set_deferred("collision_enabled", is_down)
		back.set_deferred("collision_enabled", !is_down)
		middle.set_deferred("collision_enabled", !is_down)
		fore.set_deferred("collision_enabled", !is_down)

		if tw: tw.kill()
		tw = create_tween().set_parallel()

		tw.tween_property(back, ^"modulate:a", 0.0 if is_down else 1.0 , 1.0)
		tw.tween_property(middle, ^"modulate:a", 0.0 if is_down else 1.0 , 1.0)
		tw.tween_property(fore, ^"modulate:a", 0.0 if is_down else 1.0 , 1.0)
		tw.tween_property(lower, ^"modulate:a", 1.0 if is_down else 0.0 , 1.0)
