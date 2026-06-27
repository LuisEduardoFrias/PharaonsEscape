@tool class_name MechanicalDoor extends Node2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var color: ColorRect = $ColorRect
@onready var body_shape: CollisionShape2D = $StaticBody2D/CollisionShape2D

@export var opening: bool = false
@export var invert: bool = false:
	set(val):
		invert = val
		if not is_node_ready(): await ready
		if val:
			anim.position = Vector2(0.0, -64)
			anim.rotation_degrees = 180.0
		else:
			anim.position = Vector2(0.0, 0.0)
			anim.rotation_degrees = 0.0




var state_on: bool = false


func _ready() -> void:
	if opening:
		state_on = true
		color.set_deferred("color:a", 0.0)
		anim.play(&"default_open")
		body_shape.set_deferred("disabled", true)


func _open() -> void:
	if !state_on: _action()


func _close() -> void:
	if state_on: _action(false)


func _action(val: bool = true) -> void:
	state_on = val
	var tw: Tween = create_tween()
	tw.tween_property(color, ^"color:a", 0.0 if state_on else 1.0, 1.0)

	if state_on:
		anim.play(&"open")
		body_shape.set_deferred("disabled", true)
	else:
		anim.play_backwards(&"open")
		body_shape.set_deferred("disabled", false)

	await anim.animation_finished
	if state_on: anim.play(&"default_open")
	else: anim.play(&"default_close")
