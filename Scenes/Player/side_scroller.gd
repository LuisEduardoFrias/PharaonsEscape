extends Node

var jump_force: float = 48.0


func _on_physics_process(_delta: float, player: Player) -> void:
	if player.is_control_off:
		return

	# Obtenemos el vector, pero forzamos el eje Y a 0 para movimiento puramente horizontal
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	direction.y = 0.0

	if direction.length() < 0.5:
		direction = Vector2.ZERO

	player.current_direction = direction
	player.ray.target_position = (direction * player.current_direction)

	if direction != Vector2.ZERO:
		player.old_direction = direction.normalized()
		player.velocity = player.old_direction * player.speed
	else:
		player.velocity = Vector2.ZERO

	# El volteo se ejecuta basándose estrictamente en la dirección horizontal
	if player.old_direction.x > 0:
		player.sprite_node.flip_h = true
		player.hit.scale = Vector2(-1.0, 1.0)
	elif player.old_direction.x < 0:
		player.sprite_node.flip_h = false
		player.hit.scale = Vector2(1.0, 1.0)

	player.move_and_slide()
