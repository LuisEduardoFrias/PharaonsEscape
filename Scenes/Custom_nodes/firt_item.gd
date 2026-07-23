@tool extends Node2D

enum Type_Item { COINT, DAGGER, PARCHMENT }


@export var type_Item: Type_Item = Type_Item.COINT
@export var anim: Node2D = null:
	set(val):
		anim = val
		if not is_node_ready(): await ready
		anim.position = Vector2(0.0, -36.0)


func _ready() -> void:
	match type_Item:
		Type_Item.PARCHMENT, Type_Item.COINT:
			if Global.hidden_item(ItemsData.ItemType.COIN if (type_Item == Type_Item.COINT) else ItemsData.ItemType.PARCHMENTS): queue_free()
		Type_Item.DAGGER:
			if Global.hidden_skill(SkillsData.SkillsType.SWORD): queue_free()


func _interact(_data: Dictionary) -> void:
	match type_Item:
		Type_Item.PARCHMENT:
			Global.add_item(ItemsData.ItemType.PARCHMENTS, 0)
		Type_Item.COINT:
			Global.add_item(ItemsData.ItemType.COIN)
		Type_Item.DAGGER:
			Global.add_skill(SkillsData.SkillsType.SWORD)
	queue_free()


func _on_item_body_entered(body: Node2D) -> void:
	if body is Player:
		body.interactive_object = self


func _on_item_body_exited(body: Node2D) -> void:
	if body is Player:
		body.interactive_object = null
