extends SectionBase

@onready var escalator: Escalator = $platform/escalator
@onready var escalator2: Escalator = $platform/escalator2
@onready var escalator3: Escalator = $platform/escalator3
@onready var escalator4: Escalator = $platform/escalator4
@onready var lever: StaticBody2D = $objs/floor_lever
@onready var lever2: StaticBody2D = $objs/floor_lever2
@onready var lever3: StaticBody2D = $objs/floor_lever3
@onready var elevate_tile: Area2D = $area/bridge/elevate_tile
@onready var lower_tile: Area2D = $area/bridge/lower_tile
@onready var bridge: Bridge = $area/bridge
@onready var bridge2: Bridge = $area/bridge2
@onready var bridge3: Bridge = $area/bridge3
@onready var camera2: Camera2D = $Camera2D


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


func _on_change_camera_body_entered(body: Node2D) -> void:
	if body is Player:
		camera.enabled = false
		camera2.enabled = true


func _on_change_camera_body_exited(body: Node2D) -> void:
	if body is Player:
		camera2.enabled = false
		camera.enabled = true


func _on_floor_lever_2_is_activated(on: bool) -> void:
	if on: escalator3._open()


func _on_floor_lever_3_is_activated(on: bool) -> void:
	if on: escalator4._open()


func _on_bridge_2_is_jumping(on: bool) -> void:
	bridge3.jumping = on

	if not on:
		escalator4._close()
		lever3.is_active = false


func _on_bridge_3_is_jumping(on: bool) -> void:
	bridge2.jumping = on

	if not on:
		escalator3._close()
		lever2.is_active = false


func _on_bridge_is_jumping(on: bool) -> void:
	if not on:
		escalator2._close()
		lever.is_active = false
