extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body is Jug:
		body.pushable.direction = Vector2.ZERO
		var tween := get_tree().create_tween()
		tween.tween_property(body, "position", position, 0.1)
		tween.tween_callback(func()-> void:
			body.fall()
		)
