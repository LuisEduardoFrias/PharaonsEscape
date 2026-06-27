extends Node2D

@export var enemigo_scene: PackedScene # Arrastra aquí tu escena de Enemigo (.tscn)
@export var castillo_node: Node2D      # Arrastra aquí el nodo del Castillo desde el panel de propiedades
@export var tiempo_spawn: float = 2.0

@onready var timer: Timer = Timer.new()

func _ready() -> void:
	# Inicializa la semilla aleatoria para que el dispositivo mezcle de verdad los niveles 1, 2, 3 y 4
	randomize()

	# Configurar y añadir el Timer de spawn de forma dinámica
	add_child(timer)
	timer.wait_time = tiempo_spawn
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout() -> void:
	if not enemigo_scene or not castillo_node:
		print("Falta asignar la escena del enemigo o el nodo del castillo en el inspector.")
		return

	# Instanciar enemigo
	var nuevo_enemigo = enemigo_scene.instantiate()

	# --- ASIGNACIÓN DE NIVEL ORDENADA (1, 2, 3 o 4) ---
	# Generamos un nivel entero puro del 1 al 4. El script del enemigo multiplicará este valor
	# por 5 en su _ready() para obtener sus 5, 10, 15 o 20 de vida y daño exactos.
	nuevo_enemigo.vida = randi_range(1, 4)

	# Corregido: Usamos TAU en lugar de TWO_PI para el círculo completo (360 grados)
	var angulo_aleatorio = randf() * TAU
	var radio_spawn = 400.0 # Ajusta según el tamaño de tu pantalla
	nuevo_enemigo.global_position = global_position + Vector2(cos(angulo_aleatorio), sin(angulo_aleatorio)) * radio_spawn

	# Buscamos el Area2D dentro del nodo del castillo asignado
	var castillo_area = castillo_node

	if castillo_area:
		nuevo_enemigo.castle = castillo_area
	else:
		print("No se encontró un nodo llamado 'Area2D' dentro del Castillo asignado.")

	# Añadir el enemigo a la escena principal de forma idéntica a tu código original
	get_parent().add_child(nuevo_enemigo)
