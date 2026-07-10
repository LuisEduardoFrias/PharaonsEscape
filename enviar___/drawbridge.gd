@tool extends Node2D #drawextends

enum Type { TYPE1, TYPE2 }

@export var type: Type = Type.TYPE1:
	set(val):
		type = val
		change_type(val)


func change_type(val: Type) -> void:
	match val:
		Type.TYPE1:
			$TileMapLayer.set_cell(Vector2i(1,0), 1, Vector2i(0, 0))
		Type.TYPE2:
			var transfor: int = TileSetAtlasSource.TRANSFORM_TRANSPOSE
			$TileMapLayer.set_cell(Vector2i(1,0), 1, Vector2i(1,0), transfor)


func _on_area_body_entered(body: Node2D) -> void:
	if body is Player:
		z_index = 1
		z_as_relative = false


func _on_area_body_exited(body: Node2D) -> void:
	if body is Player:
		z_index = 0
		z_as_relative = true
