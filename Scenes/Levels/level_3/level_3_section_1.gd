extends SectionBase

@onready var abtn1 = $area/show_btn
@onready var abtn2 = $area/show_btn2
@onready var abtn3 = $area/show_btn3

@onready var sarcofago: AnimatedSprite2D = $platform/sarcofago/animated
@onready var door1: MechanicalDoor = $doors/mechanical_door
@onready var door2: MechanicalDoor = $doors/mechanical_door2
@onready var door3: MechanicalDoor = $doors/mechanical_door3
@onready var door4: MechanicalDoor = $doors/mechanical_door4


func _ready() -> void:
	super()
	if Global.data.is_initial:
		_initial_game()
		show_title._play(CurrentLevelData.Titles.The_Grand_Gallery)
	else:
		change_scene_screen.transition_in(4.0)
		sarcofago.play(&"on")
		Global.check_door(LevelsData.Levels.LEVEL3, name, door1)
		Global.check_door(LevelsData.Levels.LEVEL3, name, door2)
		Global.check_door(LevelsData.Levels.LEVEL3, name, door3)
		Global.check_door(LevelsData.Levels.LEVEL3, name, door4)

	if door1.opening: abtn1.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		$area/show_btn/dialog_trigger.data = { "_open_door": func () -> void:
			Global.save_open_door(LevelsData.Levels.LEVEL3, name, door1)
			abtn1.process_mode = Node.PROCESS_MODE_DISABLED
		}

	if door2.opening: abtn2.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		$area/show_btn2/dialog_trigger2.data = { "_open_door": func () -> void:
			Global.save_open_door(LevelsData.Levels.LEVEL3, name, door2)
			abtn2.process_mode = Node.PROCESS_MODE_DISABLED
		}

	if door3.opening: abtn3.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		$area/show_btn3/dialog_trigger3.data = { "_open_door": func () -> void:
			Global.save_open_door(LevelsData.Levels.LEVEL3, name, door3)
			abtn3.process_mode = Node.PROCESS_MODE_DISABLED
		}


func _initial_game() -> void:
	change_scene_screen.transition_out(0.0)
	player.state_machine.playback.travel("stop_invisible")
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

	Global.data.is_initial = false
	Global.save()


func _on_switch_switch(on: bool) -> void:
	if on:
		Global.save_open_door(LevelsData.Levels.LEVEL3, name, door4)


func _on_firt_item_interac(item: int) -> void:
	match item:
		2: Global.add_item(ItemsData.ItemType.PARCHMENTS, 0)
		1: Global.add_skill(SkillsData.SkillsType.SWORD)
		0: Global.add_item(ItemsData.ItemType.COIN)
