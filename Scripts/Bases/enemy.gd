# Enemy.gd
class_name Enemy
extends Entity

@export_group("Combat Stats")
@export var max_health: float = 100.0
@export var current_health: float = 100.0:
	set(value):
		current_health = clamp(value, 0, max_health)
		if current_health <= 0:
			die()

@export var damage: float = 10.0
@export var knockback_force: float = 150.0

@export_group("AI Behavior")
@export var detection_radius: float = 200.0
@export var chase_speed: float = 150.0
@export var patrol_speed: float = 80.0

# Referencia al objetivo actual (normalmente el Player)
var target: CharacterBody2D = null

## Método para recibir daño con parámetros opcionales
func take_damage(amount: float, attacker_pos: Vector2 = Vector2.ZERO):
	current_health -= amount

	# Aquí podrías llamar a play_sound con un pitch aleatorio para el golpe
	# play_sound(hit_sfx, -2.0, randf_range(0.9, 1.1))

	print(name, " recibió daño. Vida restante: ", current_health)

	if attacker_pos != Vector2.ZERO:
		apply_knockback(attacker_pos)

## Lógica de retroceso al ser golpeado
func apply_knockback(source_position: Vector2):
	var push_direction = (global_position - source_position).normalized()
	velocity = push_direction * knockback_force
	move_and_slide()

## Método abstracto para la muerte
func die():
	# Emitir señales, desactivar colisiones, soltar loot, etc.
	print(name, " ha muerto.")
	queue_free()

## Función para detectar si el objetivo está en rango (Útil para los Estados)
func is_target_in_range() -> bool:
	if target:
		return global_position.distance_to(target.global_position) <= detection_radius
	return false
