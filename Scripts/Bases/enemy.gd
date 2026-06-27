# Enemy.gd
class_name Enemy
extends Entity

signal is_dead()

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
@export var hit_box: Area2D
@export var hurt_box: Area2D


func _ready() -> void:
	hurt_box.area_entered.connect(_hurt_area_entered)


## Método para recibir daño con parámetros opcionales
func take_damage(amount: float, attacker_pos: Vector2 = Vector2.ZERO):
	current_health -= amount
	animation_effect()

	# Aquí podrías llamar a play_sound con un pitch aleatorio para el golpe
	# play_sound(hit_sfx, -2.0, randf_range(0.9, 1.1))

	print(name, " recibió daño. Vida restante: ", current_health)

	if attacker_pos != Vector2.ZERO:
		apply_knockback(attacker_pos)


func animation_effect() -> void:
	pass


func appearance() -> void:
	pass


func _hurt_area_entered(area: Area2D) -> void:
	if area.name == "hit" and (area.get_parent() as Player):
		take_damage(25)


## Lógica de retroceso al ser golpeado
func apply_knockback(source_position: Vector2):
	var push_direction = (global_position - source_position).normalized()
	velocity = push_direction * knockback_force
	move_and_slide()


## Método abstracto para la muerte
func die():
	# Emitir señales, desactivar colisiones, soltar loot, etc.
	is_dead.emit()
	print(name, " ha muerto.")
	queue_free()
