extends Area2D

signal switch(on: bool)

@export var invisible: bool = false
@export var active: bool = false:
	set(val):
		active =  val
		if not is_node_ready(): await ready
		if one_activation:
			set_deferred("monitoring", false)
			set_deferred("monitorable", false)

		switch.emit(val)
		$AnimatedSprite2D.play(&"active" if !val else &"desactive")
@export var one_activation: bool = true


func _ready() -> void:
	if invisible:
		monitoring = false
	else:
		$Sprite2D.visible = false

	body_entered.connect(_body_entered)
	body_exited.connect(_body_exited)


func _interact(_data: Dictionary) -> void:
	if one_activation and active:
		return
	active = !active


func _body_entered(body: Node2D) -> void:
	if body is Player:
		body.interactive_object = self


func _body_exited(body: Node2D) -> void:
	if body is Player:
		body.interactive_object = null
