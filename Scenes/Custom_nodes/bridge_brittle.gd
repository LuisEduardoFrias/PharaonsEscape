extends Sprite2D

signal brittle

@onready var bridge: Area2D = $bridge


func _ready() -> void:
	pass#animate_bridge_collapse()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		fall(body)


func animate_bridge_collapse() -> Signal:
	var tw:Tween = create_tween()
	tw.tween_property(self, ^"frame", 14, 1.0)
	brittle.emit()
	return tw.finished


func _on_bridge_body_entered(body: Node2D) -> void:
	if body is Player:
		body.in_bridge = true


func _on_bridge_body_exited(body: Node2D) -> void:
	if body is Player:
		body.in_bridge = false


func fall(player: Player) -> void:
	player._input_physics_off(true)
	await Util.timerout(1.0)
	player.show_quetion(true)
	await animate_bridge_collapse()
	player.old_direction = Vector2.DOWN
