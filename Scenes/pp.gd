extends Node2D

signal castillo_destruido

@onready var lb : Label = $CanvasLayer/Label/Label2
@onready var vida_: Label = $CanvasLayer/Label3/vida

@export var vida_maxima: int = 100

var vida_actual: int:
	set(val):
		# Aseguramos que la vida no baje de 0
		vida_actual = max(0, val)
		# Si el nodo ya está listo en el árbol, actualizamos la interfaz
		if is_inside_tree() and vida_:
			vida_.text = str(vida_actual)

var puntos: int = 0:
	set(val):
		puntos = val
		lb.text = str(puntos)

func _ready() -> void:
	# Al asignar usando 'self.', forzamos a Godot a ejecutar el setter desde el inicio
	self.vida_actual = vida_maxima
	self.puntos = 0

# Conecta la señal 'area_entered' de la Area2D del castillo a esta función
func _on_castle_area_entered(area: Area2D) -> void:
	# Buscamos al dueño del área que entra (raíz CharacterBody2D del enemigo)
	var enemigo = area.owner

	if enemigo and "danio" in enemigo:
		recibir_danio(enemigo.danio)
		# El enemigo se elimina inmediatamente tras hacer daño
		enemigo.queue_free()

func recibir_danio(cantidad: int) -> void:
	# Corregido: Usamos 'self.' para que pase por el 'set(val)' y actualice el Label
	self.vida_actual -= cantidad
	if vida_actual <= 0:
		emit_signal("castillo_destruido")

func sumar_puntos(cantidad: int) -> void:
	# Corregido: Usamos 'self.' para que pase por el 'set(val)' y actualice el Label de puntos
	self.puntos += cantidad
