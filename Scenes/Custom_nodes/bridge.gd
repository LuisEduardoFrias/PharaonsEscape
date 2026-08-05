class_name Bridge extends Node2D

signal is_jumping(on: bool)

enum Dir { UP, RIGHT, DOWN, LEFT }

@onready var elevate_tile: Area2D = $elevate_tile
@onready var lower_tile: Area2D = $lower_tile
@onready var auto_jump1: Area2D = $auto_jump1
@onready var auto_jump2: Area2D = $auto_jump2
@onready var bridge: StaticBody2D = $bridge

var active: bool = false

@export var jumping: bool = false:
	set(val):
		jumping = val
		if not is_node_ready(): await ready
		active_bridge(val)
@export var dir_auto_jump1: Dir = Dir.DOWN:
	set(val):
		dir_auto_jump1 = val
		if not is_node_ready(): await ready
		auto_jump1.direction = val
@export var dir_auto_jump2: Dir = Dir.DOWN:
	set(val):
		dir_auto_jump2 = val
		if not is_node_ready(): await ready
		auto_jump2.direction = val
@export var middle: TileMapLayer = null
@export var background: TileMapLayer = null
@export var lower_level: TileMapLayer = null
@export var elevate_shape: CollisionShape2D = null:
	set(val):
		elevate_shape = val
		if not is_node_ready(): await ready
		val.get_parent().remove_child(val)
		elevate_tile.add_child(val)
@export var lower_shpe: CollisionShape2D = null:
	set(val):
		lower_shpe = val
		if not is_node_ready(): await ready
		val.get_parent().remove_child(val)
		lower_tile.add_child(val)
@export var auto_jump_shape1: CollisionShape2D = null:
	set(val):
		auto_jump_shape1 = val
		if not is_node_ready(): await ready
		val.get_parent().remove_child(val)
		auto_jump1.add_child(val)
@export var auto_jump_shepe2: CollisionShape2D = null:
	set(val):
		auto_jump_shepe2 = val
		if not is_node_ready(): await ready
		val.get_parent().remove_child(val)
		auto_jump2.add_child(val)
@export var bridge1: CollisionShape2D = null:
	set(val):
		bridge1 = val
		if not is_node_ready(): await ready
		val.get_parent().remove_child(val)
		bridge.add_child(val)
@export var bridge2: CollisionShape2D = null:
	set(val):
		bridge2 = val
		if not is_node_ready(): await ready
		val.get_parent().remove_child(val)
		bridge.add_child(val)


func _on_elevate_tile_body_entered(body: Node2D) -> void:
	if body is Player:
		background.z_index = 2
		middle.z_index = 2
		background.light_mask = 0
		background.collision_enabled = false


func _on_elevate_tile_body_exited(body: Node2D) -> void:
	if body is Player:
		background.z_index = 0
		middle.z_index = 1
		background.light_mask = 1
		background.collision_enabled = true


func _on_auto_jump_jumping() -> void:
	jumping = true


func _on_lower_tile_body_entered(body: Node2D) -> void:
	if body is Player: jumping = false


func active_bridge(on: bool) -> void:
	lower_tile.monitoring = on
	lower_level.collision_enabled = on
	bridge.set_collision_layer_value(1, !on)
	await Util.timerout(0.5)
	elevate_tile.monitoring = on

	if on and not active:
		active = true
		is_jumping.emit(on)
	if not on and active:
		active = on
		is_jumping.emit(on)
