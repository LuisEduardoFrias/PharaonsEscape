@tool extends Node2D

@onready var door1: AnimatedSprite2D = $door1
@onready var door2: AnimatedSprite2D = $door2
@onready var tile: TileMapLayer = $TileMapLayer

enum Types { TYPE_1, TYPE_2 }

enum WallType {
	wall_1, wall_2, wall_3, wall_4,
	concave_corner_1, concave_corner_2, concave_corner_3, concave_corner_4,
	corner_1, corner_2, corner_3,
}

@export var wall_1 : WallType = WallType.concave_corner_1:
	set(val):
		wall_1 = val
		if not is_node_ready(): await ready
		update_wall()

@export var wall_2 : WallType = WallType.concave_corner_1:
	set(val):
		wall_2 = val
		if not is_node_ready(): await ready
		update_wall()

@export var type: Types = Types.TYPE_1:
	set(val):
		type = val
		if not is_node_ready(): await ready
		animation = &"open_close_type_1" if val == Types.TYPE_1 else &"open_close_type_2"
		door1.animation = animation
		door2.animation = animation

var animation : StringName = &"open_close_type_1"

@export var owner_name: LevelsData.Levels = LevelsData.Levels.LEVEL1

func _ready() -> void:
	if Global.check_door(owner_name, name) : _open()
	#TODO verificar en global si esta puerta está registrada por su nombre para abrirla o no


func _open() -> void:
	door1.play(animation)
	door2.play(animation)
	door1.animation_finished.connect(func () -> void: $static_body/collision.set_deferred("disabled", true), CONNECT_ONE_SHOT)


func _close() -> void:
	door1.play_backwards(animation)
	door2.play_backwards(animation)
	door1.animation_finished.connect(func () -> void: $static_body/collision.set_deferred("disabled", false), CONNECT_ONE_SHOT)


func _on_area_body_entered(body: Node2D) -> void:
	if body is Player:
		self.z_index = 1


func _on_area_body_exited(body: Node2D) -> void:
	if body is Player:
		self.z_index = 0


func update_wall() -> void:
	match_wall(wall_1, Vector2(0, -1))
	match_wall(wall_2, Vector2i(1, -1), true)


func match_wall(wall: WallType, cord_wall: Vector2i, invest: bool = false) -> void:
	var trans : int

	if !invest:
		trans = TileSetAtlasSource.TRANSFORM_FLIP_H

	match wall:
		WallType.wall_1:
			trans = trans | TileSetAtlasSource.TRANSFORM_TRANSPOSE
			tile.set_cell(cord_wall, 1, Vector2i(1, 0), trans)
		WallType.wall_2:
			trans = trans | TileSetAtlasSource.TRANSFORM_TRANSPOSE
			tile.set_cell(cord_wall, 1, Vector2i(1, 1), trans)
		WallType.wall_3:
			trans = trans | TileSetAtlasSource.TRANSFORM_TRANSPOSE
			tile.set_cell(cord_wall, 1, Vector2i(1, 2), trans)
		WallType.wall_4:
			trans = trans | TileSetAtlasSource.TRANSFORM_TRANSPOSE
			tile.set_cell(cord_wall, 1, Vector2i(1, 3), trans)
		WallType.concave_corner_1:
			trans = trans | TileSetAtlasSource.TRANSFORM_TRANSPOSE
			tile.set_cell(cord_wall, 1, Vector2i(0, 0), trans)
		WallType.concave_corner_2:
			trans = trans | TileSetAtlasSource.TRANSFORM_TRANSPOSE
			tile.set_cell(cord_wall, 1, Vector2i(0, 1), trans)
		WallType.concave_corner_3:
			trans = trans | TileSetAtlasSource.TRANSFORM_TRANSPOSE
			tile.set_cell(cord_wall, 1, Vector2i(0, 2), trans)
		WallType.concave_corner_4:
			trans = trans | TileSetAtlasSource.TRANSFORM_TRANSPOSE
			tile.set_cell(cord_wall, 1, Vector2i(0, 3), trans)
		WallType.corner_1:
			trans = trans | TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_V
			tile.set_cell(cord_wall, 1, Vector2i(2, 0), trans)
		WallType.corner_2:
			trans = trans | TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_V
			tile.set_cell(cord_wall, 1, Vector2i(2, 1), trans)
		WallType.corner_3:
			trans = trans | TileSetAtlasSource.TRANSFORM_TRANSPOSE | TileSetAtlasSource.TRANSFORM_FLIP_V
			tile.set_cell(cord_wall, 1, Vector2i(2, 3), trans)
