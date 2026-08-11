@tool extends Sprite2D

enum Type_mode { TYPE1, TYPE2 }

@onready var _floor: Sprite2D = $floor

@export var type_mode: Type_mode = Type_mode.TYPE1:
	set(val):
		type_mode = val
		if not is_node_ready(): await ready
		var x: float = 640.0 if val == Type_mode.TYPE2 else 704.0
		texture.region = Rect2( x , 0.0, 64.0, 64.0 )

var player: Player


func _ready() -> void:
	texture = texture.duplicate()


func _interact(_data: Dictionary) -> void:
	player._input_physics_off(true)
	Global.data.player.purified()
	player._input_physics_off(false)


func _on_on_save_body_entered(body: Node2D) -> void:
	if body is Player:
		_floor.texture.region  = Rect2(128.0 , 896.0, 64.0, 64.0)
		player = body
		body.interactive_object = self


func _on_on_save_body_exited(body: Node2D) -> void:
	if body is Player:
		_floor.texture.region  = Rect2(64.0, 64.0, 64.0, 64.0)
		player = null
		body.interactive_object = null
