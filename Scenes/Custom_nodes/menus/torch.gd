extends TextureRect

@onready var luz: PointLight2D = $PointLight2D

@export var energia_base: float = 0.9
@export var variacion_energia: float = 0.15
@export var velocidad_parpadeo: float = 15.0

var tiempo: float = 0.0

func _process(delta: float) -> void:
	tiempo += delta * velocidad_parpadeo
	var ruido = sin(tiempo) * cos(tiempo * 0.7)
	luz.energy = energia_base + (ruido * variacion_energia)
	luz.texture_scale = 1.5 + (ruido * 0.05)
