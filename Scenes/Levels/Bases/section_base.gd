extends Node2D
class_name SectionBase

@export var melody: AudioStream

@onready var lower_level := $lower_level
@onready var background := $background
@onready var middleground := $midground
@onready var foreground:= $foreground


## Nodo contenedor para clasificar los enemigos específicos de esta sección.
@onready var enemies_container: Node2D = $Enemies
## Nodo contenedor para clasificar los ítems recolectables de esta sección.
@onready var items_container: Node2D = $Items


func _ready() -> void:
	_clear_persisted_objects()


## Recorre los contenedores de la sección para eliminar de forma inmediata aquellos
## objetos que el jugador ya haya destruido o recogido en sesiones anteriores.
func _clear_persisted_objects() -> void:
	var section_id: String = name.to_lower()

	if enemies_container:
		for enemy in enemies_container.get_children():
			var enemy_uid: String = section_id + "_" + enemy.name.to_lower()
			if Global.data.defeated_enemies.has(enemy_uid):
				enemy.queue_free()

	if items_container:
		for item in items_container.get_children():
			var item_uid: String = section_id + "_" + item.name.to_lower()
			if Global.data.collected_items.has(item_uid):
				item.queue_free()


## Registra la derrota de un enemigo en el recurso de datos global usando un identificador único.
func register_enemy_death(enemy_node_name: String) -> void:
	var enemy_uid: String = name.to_lower() + "_" + enemy_node_name.to_lower()
	if not Global.data.defeated_enemies.has(enemy_uid):
		Global.data.defeated_enemies.append(enemy_uid)


## Registra la recolección de un ítem en el recurso de datos global usando un identificador único.
func register_item_collected(item_node_name: String) -> void:
	var item_uid: String = name.to_lower() + "_" + item_node_name.to_lower()
	if not Global.data.collected_items.has(item_uid):
		Global.data.collected_items.append(item_uid)
