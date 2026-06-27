extends Area2D

@export var section: LevelBase.Section

signal actívate_section(sect: LevelBase.Section)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		actívate_section.emit(section)
