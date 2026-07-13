extends SectionBase

@onready var escalator: Escalator = $platform/escalator
@onready var escalator2: Escalator = $platform/escalator2
@onready var elevate_tile: Area2D = $area/bridge/elevate_tile
@onready var lower_tile: Area2D = $area/bridge/lower_tile
@onready var bridge: StaticBody2D = $area/bridge/bridge


func _ready() -> void:
	super()


func _on_elevate_tile_body_entered(body: Node2D) -> void:
	if body is Player:
		background.z_index = 2
		background.light_mask = 0


func _on_elevate_tile_body_exited(body: Node2D) -> void:
	if body is Player:
		background.z_index = 0
		background.light_mask = 1


func _on_floor_lever_is_activated(on: bool) -> void:
	if on: escalator2._open()


func _on_auto_jump_jumping() -> void:
	lower_tile.monitoring = true
	lower_level.collision_enabled = true
	elevate_tile.monitoring = true
	bridge.set_collision_layer_value(1, false)


func _on_lower_tile_body_entered(body: Node2D) -> void:
	if body is Player:
		lower_tile.monitoring = false
		lower_level.collision_enabled = false
		elevate_tile.monitoring = false
		bridge.set_collision_layer_value(1, true)
