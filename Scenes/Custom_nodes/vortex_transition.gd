extends CanvasLayer

var player: Player


func _ready() -> void:
	visible = false


func transition_in(time_scale: float = 0.2) -> void:
	if player: player._input_physics_off(true)
	visible = true
	Engine.time_scale = time_scale
	$AnimationPlayer.play(&"play")
	await $AnimationPlayer.animation_finished
	Engine.time_scale = 1.0


func transition_out(time_scale: float = 0.2) -> void:
	visible = true
	Engine.time_scale = time_scale
	$AnimationPlayer.play_backwards(&"play")
	await $AnimationPlayer.animation_finished
	Engine.time_scale = 1.0
	visible = false
	if player: player._input_physics_off(true)
