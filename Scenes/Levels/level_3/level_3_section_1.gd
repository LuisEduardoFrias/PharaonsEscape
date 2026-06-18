extends SectionBase


func _ready() -> void:
	super()
	if Global.is_initial:
		await get_tree().physics_frame
		await get_tree().physics_frame
		Util.timerout(2.0).connect( func() -> void:
			player.position = Vector2(800.0, 1555.0)
		)
		Global.is_initial = false
