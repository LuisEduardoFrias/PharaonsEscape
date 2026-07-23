@tool extends StaticBody2D

signal is_activated(on: bool)

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var area: Area2D = $Area2D

@export var one_activation: bool = true
@export var is_active: bool = true:
	set(val):
		is_active = val
		if not is_node_ready(): await ready
		is_activated.emit(val)
		if one_activation and val:
			area.queue_free()
			#area.monitorable = false
			#area.monitoring = false
			set_collision_layer_value(5, false)
		if not val:
			area.monitorable = true
			area.monitoring = true
			set_collision_layer_value(5, true)
		anim.play(&"activate" if val else &"desactivate")


func _ready() -> void:
	Global.check_switch(LevelsData.Levels.LEVEL3, owner.name, self)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		body.interactive_object = self


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		body.interactive_object = null


func _interact(_data: Dictionary) -> void:
	Global.save_switch(LevelsData.Levels.LEVEL3, owner.name, self)


func active() -> void:
	is_active = !is_active


func hurt(_damage: float) -> void:
	_interact({})
