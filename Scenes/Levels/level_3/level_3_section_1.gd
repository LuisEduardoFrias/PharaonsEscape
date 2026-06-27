extends SectionBase

@onready var sarcofago: AnimatedSprite2D = $platform/sarcofago/animated
@onready var door1: MechanicalDoor = $doors/mechanical_door
@onready var door2: MechanicalDoor = $doors/mechanical_door2
@onready var door3: MechanicalDoor = $doors/mechanical_door3
@onready var door4: MechanicalDoor = $doors/mechanical_door4
@onready var door5: MechanicalDoor = $doors/mechanical_door5


func _ready() -> void:
	super()
	if Global.is_initial: _initial_game()
	else:
		change_scene_screen.transition_in(4.0)
		sarcofago.play(&"on")


func _initial_game() -> void:
	var dt  = $area/show_btn/dialog_trigger
	var dt2 = $area/show_btn2/dialog_trigger2
	var dt3 = $area/show_btn3/dialog_trigger3

	dt.monitoring = true
	dt2.monitoring = true
	dt3.monitoring = true

	dt.data = { "_open_door": func () -> void:
		door1._open()
		dt.monitorable = false
	}
	dt2.data = { "_open_door": func () -> void:
		door2._open()
		dt2.monitoring = false
	}
	dt3.data = { "_open_door": func () -> void:
		door3._open()
		dt3.monitoring = false
	}

	change_scene_screen.transition_out(0.0)
	player.visible = false
	player._input_physics_off(true)

	await get_tree().physics_frame
	await get_tree().physics_frame

	await get_tree().physics_frame
	await get_tree().physics_frame

	change_scene_screen.transition_in(4.0)
	sarcofago.play(&"default")
	await sarcofago.animation_finished
	player.visible = true
	player._input_physics_off(false)
	Global.is_initial = false


func _on_switch_switch() -> void:
	door4._open()
	door5._open()
