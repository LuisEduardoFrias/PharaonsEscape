extends Node2D

@onready var luz: PointLight2D = $PointLight2D

# Parámetros para calibrar el parpadeo
@export var energia_base: float = 0.9
@export var variacion_energia: float = 0.15
@export var velocidad_parpadeo: float = 15.0

var tiempo: float = 0.0

func _process(delta: float) -> void:
	tiempo += delta * velocidad_parpadeo

	# Usamos una función seno combinada con un ruido rápido para simular el fuego
	var ruido = sin(tiempo) * cos(tiempo * 0.7)

	# Aplicamos la variación a la energía de la luz
	luz.energy = energia_base + (ruido * variacion_energia)

	# Opcional: Pequeña variación en el tamaño para simular el movimiento de la llama
	luz.texture_scale = 1.5 + (ruido * 0.05)
