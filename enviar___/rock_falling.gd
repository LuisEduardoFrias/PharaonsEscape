@tool extends Node2D

@export var interval: float = 2.0
@export var waiting_time: float = 1.0
@export var with_activate: bool = false

var time_passed: float = 0.0
var on: bool = false


func _ready() -> void:
	#super()
	$sprite.texture = $sprite.texture.duplicate()

	if not with_activate:
		get_tree().create_timer(waiting_time).timeout \
		.connect(func () -> void: on = true)


func _process(delta: float) -> void:
	if not on:
		return

	time_passed += delta

	if time_passed >= interval:
		$sprite/AnimationPlayer.play("activate")
		time_passed = 0.0


func activate() -> void:
	await get_tree().create_timer(waiting_time).timeout
	$sprite/AnimationPlayer.play("activate")


func _on_hit_area_entered(area: Area2D) -> void:
	if area.get_parent() as Player:
		area.get_parent().hurt(global_position)
