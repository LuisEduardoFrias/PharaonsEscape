extends SectionBase

@onready var door1: MechanicalDoor = $doors/mechanical_door
@onready var door2: MechanicalDoor = $doors/mechanical_door2
@onready var escalagor1: Escalator = $platform/escalator
@onready var escalagor2: Escalator = $platform/escalator2
@onready var double_door: DoubleMechanicalDoor = $platform/double_mechanical_door
@onready var double_door2: DoubleMechanicalDoor = $platform/double_mechanical_door2

@onready var dialog: DialogTrigger = $area/show_btn/dialog_trigger


func _ready() -> void:
	super()
	show_title._play(CurrentLevelData.Titles.The_Subterranean_Trial)
	Global.check_door(LevelsData.Levels.LEVEL3, name, door1)
	Global.check_door(LevelsData.Levels.LEVEL3, name, door2)
	if not door2.opening and Global.section_2_active_door:
		Global.save_open_door(LevelsData.Levels.LEVEL3, name, door2)
	Global.check_door(LevelsData.Levels.LEVEL3, name, escalagor1)
	Global.check_door(LevelsData.Levels.LEVEL3, name, escalagor2)
	Global.check_door(LevelsData.Levels.LEVEL3, name, double_door)
	Global.check_door(LevelsData.Levels.LEVEL3, name, double_door2)
	dialog.data.set("_start_puzle", _start_puzle)

	if escalagor1.opening:
		$area/show_btn.queue_free()
		#dialog.get_parent().process_mode = Node.PROCESS_MODE_DISABLED


func _on_switch_switch(_on: bool) -> void:
	Global.save_open_door(LevelsData.Levels.LEVEL3, name, door1)


func _start_puzle() -> void:
	Global.save_open_door(LevelsData.Levels.LEVEL3, name, escalagor2)
	Global.save_open_door(LevelsData.Levels.LEVEL3, name, escalagor1)
	$area/show_btn.queue_free()


#if body is Player:
#		Global.save_open_door(LevelsData.Levels.LEVEL3, name, double_door)
#		Global.save_open_door(LevelsData.Levels.LEVEL3, name, double_door2)


func _on_fall_level_one_body_entered(body: Node2D) -> void:
	if body is Player:
		body.is_fall_level_one = true


func _on_fall_level_one_body_exited(body: Node2D) -> void:
	if body is Player:
		body.is_fall_level_one = false
