@tool class_name MechanicalDoor extends Node2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var anim2: AnimatedSprite2D = $AnimatedSprite2D2
@onready var color: ColorRect = $ColorRect
@onready var body_shape: CollisionShape2D = $StaticBody2D/CollisionShape2D

@export var double_door: bool = false:
	set(val):
		double_door = val
		if not is_node_ready(): await ready
		anim2.visible = val
		body_shape.shape = body_shape.shape.duplicate()
		body_shape.shape.size.x = 128.0 if val else 64.0
		body_shape.position.x = 64.0 if val else 32.0
		color.size.x = 256.0 if val else 192.0

@export_enum("TOP","RIGHT", "DOWN", "LEFT") var direction: String = "TOP":
	set(val):
		direction = val
		if not is_node_ready(): await ready
		match val:
			"TOP":
				rotation_degrees = 0
				scale.x = 1
			"RIGHT":
				rotation_degrees = 90
				scale.x = 1
			"DOWN":
				rotation_degrees = 180
				scale.x = -1
			"LEFT":
				rotation_degrees = 270
				scale.x = -1

@export var opening: bool = false:
	set(val):
		opening = val
		if not is_node_ready(): await ready
		state_on = val
		color.color.a = 0.0 if val else 1.0
		anim.play(&"default_open" if val else &"default_close")
		anim2.play(&"default_open" if val else &"default_close")
		body_shape.set_deferred("disabled", val)

@export var invert: bool = false:
	set(val):
		invert = val
		if not is_node_ready(): await ready
		anim.scale.y = -1 if val else 1
		anim2.scale.y = -1 if val else 1
		color.scale.y = 1 if val else -1


var state_on: bool = false

func _ready() -> void:
	body_shape.shape = body_shape.shape.duplicate()

func _open() -> void:
	if !state_on: _action()


func _close() -> void:
	if state_on: _action(false)


func _action(val: bool = true) -> void:
	state_on = val
	var tw: Tween = create_tween()
	tw.tween_property(color, ^"color:a", 0.0 if state_on else 1.0, 1.0)

	anim.play(&"open" if val else &"close")
	anim2.play(&"open" if val else &"close")
	body_shape.set_deferred("disabled", val)

	await anim.animation_finished
	anim.play(&"default_open" if val else &"default_close")
	anim2.play(&"default_open" if val else &"default_close")
