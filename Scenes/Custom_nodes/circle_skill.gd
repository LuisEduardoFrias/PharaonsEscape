extends Node2D

@onready var anim1: AnimatedSprite2D = $Anim_1
@onready var anim2: AnimatedSprite2D = $Anim_2
@onready var area1: Area2D = $area_1
@onready var area2: Area2D = $area_2

@export var child: Skill


func _ready() -> void:
	child.set_skill.connect(func () -> void:
		anim1.play_backwards("default")
		area1.queue_free()
		anim2.play_backwards("default")
		area2.queue_free(),
	CONNECT_ONE_SHOT)


func _on_area_1_body_entered(body: Node2D) -> void:
	if body is Player and child and body.current_direction.y == -1.0:
		anim1.play("default")


func _on_area_1_body_exited(body: Node2D) -> void:
	if body is Player and child and body.current_direction.y == 1.0:
		anim1.play_backwards("default")


func _on_area_2_body_entered(body: Node2D) -> void:
	if body is Player and child and body.current_direction.y == -1.0:
		anim2.play("default")


func _on_area_2_body_exited(body: Node2D) -> void:
	if body is Player and child and body.current_direction.y == 1.0:
		anim2.play_backwards("default")
