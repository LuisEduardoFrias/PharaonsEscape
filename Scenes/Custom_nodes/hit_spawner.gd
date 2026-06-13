# DESCRIPCIÓN: Componente genérico para gestionar zonas de peligro (daño) y puntos de retorno
# cronológicos (checkpoints/hooks) sin importar el tipo de nodo de colisión (Shape o Polygon).
# INSTRUCCIONES:
# 1. Añade este script a un Area2D.
# 2. Crea nodos hijos de colisión (CollisionShape2D o CollisionPolygon2D).
# 3. En el inspector de cada hijo, añade un Metadato (Sección 'Meta') según corresponda:
#    - Para puntos seguros: añade un metadato llamado "type" de tipo String con el valor "point".
#    - Para zonas de daño: añade un metadato llamado "type" de tipo String con el valor "hurt".

extends Area2D

var last_safe_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	body_shape_entered.connect(_on_body_shape_entered)

func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if not body is Player:
		return

	var owner_id: int = shape_find_owner(local_shape_index)
	var collision_node = shape_owner_get_owner(owner_id)

	if collision_node.has_meta(&"type"):
		var zone_type: String = collision_node.get_meta(&"type")

		if zone_type == "point":
			last_safe_position = collision_node.global_position

		elif zone_type == "hurt":
			if body.has_method("hurt"):
				body.hurt(15,Vector2.ZERO,EntityBase.TypesImpact.RESPAWNER)

			if last_safe_position != Vector2.ZERO:
				_respawn_player(body)

func _respawn_player(player: Node2D) -> void:
	(player as Player).spawnd_pointer = last_safe_position
