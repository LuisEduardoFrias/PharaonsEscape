class_name DialogTrigger extends Area2D

@export var dialog_resouce: DialogueResource

@onready var exclamation: AnimatedSprite2D = $exclamation
@onready var interactive_prompt: Control = $interactive_prompt
@onready var key_label: Label = $interactive_prompt/key_label

signal player_in_out(is_entered: bool)
signal dialogue_active(is_on: bool)

const DIALOG_START:= "start"

var data : Dictionary


func _ready() -> void:
	pass


func _interact() -> void:
	monitoring = false
	dialogue_active.emit(true)
	DialogueManager.show_dialogue_balloon(dialog_resouce, DIALOG_START, [self, { "obj" = data, }])


func enable() -> void:
	dialogue_active.emit(false)
	monitoring = true


func _on_body_entered(body: Node) -> void:
	if body is Player:
		body.interactive_object = self
		player_in_out.emit(true)
		exclamation.visible = false
		interactive_prompt._show()


func _on_body_exited(body: Node) -> void:
	if body is Player:
		body.interactive_object = null
		player_in_out.emit(false)
		interactive_prompt._hide()
		if monitoring == true: exclamation.visible = true
