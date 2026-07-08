@tool class_name WallGapRoll extends BaseWall

enum WallType { roll_1, roll_2, roll_3, roll_4 }

@onready var open_wall_area :CollisionShape2D = $open_wall_gap/Collision
@onready var collision :CollisionShape2D = $static_body/collision
@onready var tml: TileMapLayer = $tile_map_layer

var unblock_sprite_1 := Vector2i(7, 0)
var unblock_sprite_2 := Vector2i(7, 1)
var unblock_sprite_3 := Vector2i(7, 2)
var unblock_sprite_4 := Vector2i(7, 3)
var block_sprite_1 :=   Vector2i(5, 0)
var block_sprite_2 :=   Vector2i(5, 1)
var block_sprite_3 :=   Vector2i(5, 2)
var block_sprite_4 :=   Vector2i(5, 3)
var block_sprite:   Vector2i = block_sprite_1
var unblock_sprite: Vector2i = unblock_sprite_1


@export var is_block: bool = true:
	set(val):
		is_block = val
		if not is_node_ready(): await ready
		update()


@export var wall: WallType = WallType.roll_1:
	set(val):
		wall = val
		if not is_node_ready(): await ready
		match val:
			WallType.roll_1:
				block_sprite = block_sprite_1
				unblock_sprite = unblock_sprite_1
			WallType.roll_2:
				block_sprite = block_sprite_2
				unblock_sprite = unblock_sprite_2
			WallType.roll_3:
				block_sprite = block_sprite_3
				unblock_sprite = unblock_sprite_3
			WallType.roll_4:
				block_sprite = block_sprite_4
				unblock_sprite = unblock_sprite_4
		update()

@export var owner_name: LevelsData.Levels = LevelsData.Levels.LEVEL1


func _ready() -> void:
	pass
	'''if is_block:
		var value: Variant = Global.check_door(owner_name, name)
		if value != null:
			is_block = value'''


func update() -> void:
	var reg :=  block_sprite if is_block else unblock_sprite
	tml.set_cell(Vector2i(0, 0), 1, reg)
	tml.set_cell(Vector2i(0, -1), 1, reg, TileSetAtlasSource.TRANSFORM_FLIP_V )
	tml.notify_property_list_changed()


func open() -> void:
	if not is_block:
		z_index = 1
		collision.disabled = true


func close() -> void:
	z_index = 0
	collision.set_deferred("disabled", false)


func unblock() -> void:
	is_block = false
	Global.open_door(owner_name, name)


func _on_open_wall_gap_body_exited(body: Node2D) -> void:
	if body is Player:
		#body.wall_gap = null
		z_index = 0
		#close()


func _on_open_wall_gap_body_entered(body: Node2D) -> void:
	if body is Player:
		pass
		#body.wall_gap = self


func _on_close_body_exited(body: Node2D) -> void:
	if body is Player:
		close()
