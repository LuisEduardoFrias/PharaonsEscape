extends Area2D
class_name SectionPortal

## El identificador de la sección de destino (ej. "section_2", "section_center").
@export var target_section: String = ""

## Señal que se emite al nivel para notificar que el jugador intentó cruzar.
signal player_entered_portal(destination_section: String)


func _ready() -> void:
	body_entered.connect(_on_body_entered)


## Callback interno del motor cuando un cuerpo físico entra al área.
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not target_section.is_empty():
		player_entered_portal.emit(target_section)
