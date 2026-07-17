@tool extends Node2D

enum Type_Item { COINT, DAGGER, PARCHMENT }

signal interac(item: Type_Item)

@export var type_Item: Type_Item = Type_Item.COINT
@export var anim: Node2D = null:
	set(val):
		anim = val
		if not is_node_ready(): await ready
		anim.position = Vector2(0.0, -36.0)


func _interact(_data: Dictionary) -> void:
	interac.emit(type_Item)
	queue_free()


func _on_item_body_entered(body: Node2D) -> void:
	if body is Player:
		body.interactive_object = self


func _on_item_body_exited(body: Node2D) -> void:
	if body is Player:
		body.interactive_object = null
