extends CanvasLayer

var player: Player


func _ready() -> void:
	visible = false


func transition_in() -> void:
	player._input_physics_off(true)
	visible = true
	Engine.time_scale = 0.2
	$AnimationPlayer.play("play")
	await $AnimationPlayer.animation_finished
	Engine.time_scale = 1.0


func transition_out() -> void:
	visible = true
	Engine.time_scale = 0.2
	$AnimationPlayer.play_backwards("play")
	await $AnimationPlayer.animation_finished
	Engine.time_scale = 1.0
	visible = false
	player._input_physics_off(true)
