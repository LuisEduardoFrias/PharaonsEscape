extends Area2D

signal switch

@export var invisible: bool = false

func _ready() -> void:
	if invisible:
		monitoring = false
	else:
		$Sprite2D.visible = false

	body_entered.connect(_body_entered)
	body_exited.connect(_body_exited)


func _interact(_data: Dictionary) -> void:
	switch.emit()
	$AnimatedSprite2D.play(&"active")


func _body_entered(body: Node2D) -> void:
	if body is Player:
		body.interactive_object = self


func _body_exited(body: Node2D) -> void:
	if body is Player:
		body.interactive_object = null
