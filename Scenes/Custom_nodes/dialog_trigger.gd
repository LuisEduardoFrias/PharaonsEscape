class_name DialogTrigger extends Area2D

@export var dialog_resouce: DialogueResource

signal dialogue_active(is_on: bool)

const DIALOG_START:= "start"

var data : Dictionary = {}


func _ready() -> void:
	pass


func _interact(_data: Dictionary) -> void:
	monitoring = false
	dialogue_active.emit(true)
	data.merge(_data)
	data.player._input_physics_off(true)
	DialogueManager.show_dialogue_balloon(dialog_resouce, DIALOG_START, [self])


func _enable() -> void:
	data.player._input_physics_off(false)
	dialogue_active.emit(false)
	monitoring = true


func _on_body_entered(body: Node) -> void:
	if body is Player:
		body.interactive_object = self


func _on_body_exited(body: Node) -> void:
	if body is Player:
		body.interactive_object = null
