# pivot_panel.gd
@tool
extends Control

var pivot_global_pos: Vector2 = Vector2.ZERO
var should_draw: bool = false


func _draw() -> void:
	if not should_draw:
		return
	var local_pos = pivot_global_pos - global_position

	draw_circle(local_pos, 22.0, Color.RED)
	draw_circle(local_pos, 10.0, Color.WHITE)
