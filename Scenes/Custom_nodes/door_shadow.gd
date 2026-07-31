@tool extends Node2D

@export var door: Door
@export_enum("UP", "DOWN", "RIGHT", "LEFT") var direction: String = "RIGHT"

@onready var sprite: Sprite2D = $sprite

const vectors = {
	"UP": Vector2.UP,
	"DOWN": Vector2.DOWN,
	"RIGHT": Vector2.RIGHT,
	"LEFT": Vector2.LEFT
}

func _ready() -> void:
	if door: door.monitoring = false
	if not door:
		push_warning("No se agrego el parámetro requerido 'Doorc'.")


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player or door and door.enabled:
		var dir: Vector2 = Door.vectors[door.direction] if door else vectors[direction]
		await body._move_to(dir, 0.7)

		if body.is_shadow_mode:
			door.monitoring = true
		else:
			body._move_to(-dir, 0.9)
