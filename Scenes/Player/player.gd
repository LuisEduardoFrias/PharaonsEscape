extends CharacterBody2D
class_name Player
# Constantes de movimiento normal
const MAX_SPEED = 250.0
const ACCELERATION = 1500.0
const FRICTION = 1800.0

# Constantes para el Dash
const DASH_SPEED = 700.0
const DASH_DURATION = 0.15 # Cuánto dura el dash en segundos
const DASH_COOLDOWN = 0.6  # Tiempo de espera para volver a usarlo

# Variables de estado del Dash
var dash_timer = 0.0
var cooldown_timer = 0.0
var is_dashing = false
var dash_direction = Vector2.ZERO

func _physics_process(delta: float) -> void:
	# Manejar timers del Dash
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false

	if cooldown_timer > 0:
		cooldown_timer -= delta

	# Obtener la dirección de movimiento (Ejes X e Y)
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# LÓGICA DE MOVIMIENTO
	if is_dashing:
		# Si está en Dash, mantiene la velocidad máxima de dash en esa dirección
		velocity = dash_direction * DASH_SPEED
	else:
		# Movimiento normal Top-Down con aceleración y fricción
		if direction != Vector2.ZERO:
			velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
		else:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)

		# ACTIVAR EL DASH (Usando la misma tecla "ui_accept" / Espacio)
		if Input.is_action_just_pressed("ui_accept") and cooldown_timer <= 0:
			# Si el jugador se está moviendo, dashea hacia allá. Si no, hacia donde mire o por defecto.
			if direction != Vector2.ZERO:
				dash_direction = direction.normalized()
			else:
				# Por defecto si está quieto (ej: derecha, o puedes usar la dirección de tu sprite)
				dash_direction = Vector2.RIGHT

			is_dashing = true
			dash_timer = DASH_DURATION
			cooldown_timer = DASH_COOLDOWN

	# Aplicar el movimiento final
	move_and_slide()
