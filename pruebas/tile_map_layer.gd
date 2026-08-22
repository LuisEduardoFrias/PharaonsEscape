extends TileMapLayer

var obj: PackedScene = load("res://pruebas/prueba.tscn")
const SIZE: float = 67.0
const MARGIN: float = 5.0
const OFFSET_Y: float = SIZE + MARGIN


func _ready() -> void:
	_instance_center()


func _instance_center() -> void:
	var instance = obj.instantiate()
	instance.position = get_viewport_rect().size / 2.0
	instance.connect("enter_body", _on_enter_body.bind(instance))
	add_child(instance)


func _on_enter_body(_body: Node2D, emitter: Node2D) -> void:
	_stack_above.call_deferred(emitter)


func _stack_above(emitter: Node2D) -> void:
	emitter.position.y -= OFFSET_Y


func _spawn_random() -> void:
	var screen_size = get_viewport_rect().size
	var rand_x = randf_range(SIZE, screen_size.x - SIZE)
	var rand_y = randf_range(SIZE, screen_size.y - SIZE)

	var instance = obj.instantiate()
	instance.position = Vector2(rand_x, rand_y)
	instance.connect("enter_body", _on_enter_body.bind(instance))
	add_child(instance)


func _on_touch_button_touch_pressed(_pressure: float) -> void:
	_spawn_random()
