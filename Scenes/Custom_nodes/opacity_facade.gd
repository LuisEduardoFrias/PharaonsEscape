extends Area2D

@export var alfa: float = 0.5
@export var opacity_only: bool = false

var tml: TileMapLayer = null
var is_opacity: bool = false

func _on_body_entered(body: Node2D) -> void:
	if body is Player and not is_opacity:
		var nodes: Array[Node] = get_children().filter(func (node: Node) -> Node: return node if node is TileMapLayer else null)

		if nodes.size() > 0:
			tml = nodes[0]

		is_opacity = true
		owner._on_opacity_facade(alfa, 1.0, tml)


func _on_body_exited(body: Node2D) -> void:
	if body is Player and not opacity_only:
		is_opacity = false
		owner._on_opacity_facade(1.0, 1.0, tml)
