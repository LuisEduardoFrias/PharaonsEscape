class_name FloorButton extends StaticBody2D

signal is_activated()

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var area: Area2D = $Area2D

@export_enum("TOP", "RIGHT", "DOWN", "LEFT") var direction: String = "TOP"

var is_active: bool = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		is_active = true
		body.position.y -= 3
		Engine.time_scale = 0.3
		await body._move_to(_directio_vt(direction), 0.2)
		Engine.time_scale = 1.0
		body._input_physics_off(true)
		is_activated.emit()
		anim.play(&"activate")
		await anim.animation_finished
		body.position.y += 3
		body._input_physics_off(false)
		area.monitoring = false


func _directio_vt(dir: String) -> Vector2:
	match dir:
		"TOP": return Vector2.UP
		"RIGHT": return Vector2.RIGHT
		"DOWN": return Vector2.DOWN
		"LEFT": return Vector2.LEFT
	return Vector2.UP


func _desactive() -> void:
	area.monitoring = true
	is_active = false
	anim.play_backwards(&"activate")
