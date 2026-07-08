extends Node2D

@export var node: PackedScene
@export var damage: float = 20.0
@export var time: float = 2.0
@export_enum("TOP", "RIGHT", "DOWN", "LEFT") var direction: String = "DOWN"
@export var enabled: bool = true:
	set(val):
		enabled = val
		if not is_node_ready(): await ready
		set_process(val)

var timer: float = 0.0


func _process(delta: float) -> void:
	timer += delta

	if timer >= time:
		timer = 0.0
		_create_node()


func _create_node() -> void:
	var inst: CharacterBody2D = node.instantiate()
	inst.damage = damage
	inst.direction = _directio_vt(direction)
	add_child(inst)


func _directio_vt(dir: String) -> Vector2:
	match dir:
		"TOP": return Vector2.UP
		"RIGHT": return Vector2.RIGHT
		"DOWN": return Vector2.DOWN
		"LEFT": return Vector2.LEFT
	return Vector2.UP
