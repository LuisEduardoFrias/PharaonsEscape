extends Node2D

signal enter_body(body: Node)


func _on_area_2d_body_entered(body: Node2D) -> void:
	enter_body.emit(body)
