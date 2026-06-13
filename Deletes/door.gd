extends Area2D

@onready var interactive_prompt: InteractivePrompt = $interactive_prompt

@export_file("*.tscn") var destination_scene: String

func _ready() -> void:
	pass # Replace with function body.


func _interact() -> void:
	assert(destination_scene != "" , "[Custom Error] : Debe asignar una escena de destino.")

	if SceneTransition: SceneTransition.transition_to(destination_scene)
	else: get_tree().change_scene_to_file(destination_scene)


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		interactive_prompt._show()
		(body as Player).interactive_object = self


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		interactive_prompt._hide()
		(body as Player).interactive_object = null
