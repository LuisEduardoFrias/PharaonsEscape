extends BossFight



func _ready() -> void:
	super()
	player.show_quetion(true)
	await Util.timerout(0.5)
	$AnimationPlayer.play(&"play")


func finiched_cinematic() -> void:
	player.show_quetion(false)
	player._input_physics_off(false)
	dialog._interact({})
