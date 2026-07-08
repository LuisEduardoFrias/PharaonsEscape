extends CharacterBody2D

@export var velocidad: float = 100.0

@export var castle: Area2D:
	set(val):
		castle = val
		if val:
			point_to_attack = val.global_position

@onready var hit : Area2D = $hit
@onready var color_rect: ColorRect = $ColorRect
@onready var collision_body: CollisionShape2D = $CollisionShape2D

var point_to_attack: Vector2
var vida: int = 1
var danio: int = 1
var puntos_al_morir: int = 1
var radio_click: float = 5.0 # Guardará el radio exacto para calcular el toque del dedo

var colores = [
	Color.GREEN,       # Nivel 1
	Color.BLUE,        # Nivel 2
	Color.YELLOW,      # Nivel 3
	Color.RED          # Nivel 4
]

func _ready() -> void:
	# Resguardamos el nivel enviado por el generador (valores del 1 al 4)
	var nivel = clamp(vida, 1, 4)

	# --- MULTIPLICACIÓN EN BASE AL NIVEL EN ENTEROS ---
	vida = nivel * 5
	danio = nivel * 5
	puntos_al_morir = nivel * 5

	# Forzar que el rectángulo ignore el mouse para que no bloquee las colisiones de Godot
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# --- TAMAÑO DINÁMICO ---
	var incremento = (nivel - 1) * 5
	var nuevo_tamano = 10.0 + incremento
	radio_click = nuevo_tamano / 2.0 # Guardamos la mitad del tamaño como radio de impacto

	color_rect.size = Vector2(nuevo_tamano, nuevo_tamano)
	color_rect.position = -color_rect.size / 2.0

	var dimensiones_vector = Vector2(nuevo_tamano, nuevo_tamano)

	# Sincronizamos las colisiones físicas y de ataque con el tamaño del rectángulo
	if collision_body and collision_body.shape is RectangleShape2D:
		collision_body.shape.size = dimensiones_vector

	var col_hit = hit.get_child(0)
	if col_hit is CollisionShape2D and col_hit.shape is RectangleShape2D:
		col_hit.shape.size = dimensiones_vector

	color_rect.color = colores[nivel - 1]
	set_process_input(true)
	print("v: ", vida, " - d: ", danio)

func _process(delta: float) -> void:
	# Movimiento constante en dirección al objetivo usando físicas de Godot 4
	if point_to_attack != Vector2.ZERO:
		var direccion = (point_to_attack - global_position).normalized()
		velocity = direccion * velocidad
		move_and_slide()

# --- DETECCIÓN TÁCTIL COMPLETA E INTEGRADA ---
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		if event.is_pressed():
			# Obtenemos la posición del toque relativa al espacio de este SubViewport
			var mouse_pos_en_viewport = get_viewport().get_mouse_position()

			# Traducimos la posición de la pantalla interna al espacio 2D del juego
			var posicion_mundo = get_viewport().canvas_transform.affine_inverse() * mouse_pos_en_viewport

			# Calculamos la distancia geométrica entre el toque y el centro de este enemigo
			var distancia = global_position.distance_to(posicion_mundo)

			# Si el dedo cae dentro del radio del enemigo (con un margen extra de 12px para pantallas táctiles)
			if distancia <= (radio_click + 12.0):
				# Evitamos que el toque se propague a otros elementos o mueva la cámara
				get_viewport().set_input_as_handled()
				recibir_danio(5) # Cada golpe certero reduce 5 puntos de vida

func recibir_danio(cantidad: int) -> void:
	vida -= cantidad
	if vida <= 0:
		# Si el enemigo muere, sumamos los puntos correspondientes antes de destruirlo
		if castle and castle.owner.has_method("sumar_puntos"):
			castle.owner.sumar_puntos(puntos_al_morir)
		queue_free()
