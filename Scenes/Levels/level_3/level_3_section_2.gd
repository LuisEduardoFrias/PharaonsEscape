extends SectionBase

@onready var door1: MechanicalDoor = $doors/mechanical_door
@onready var door2: MechanicalDoor = $doors/mechanical_door2
@onready var escalagor1: Escalator = $platform/escalator
@onready var escalagor2: Escalator = $platform/escalator2
@onready var double_door: DoubleMechanicalDoor = $platform/double_mechanical_door
@onready var double_door2: DoubleMechanicalDoor = $platform/double_mechanical_door2

@onready var dialog: DialogTrigger = $area/show_btn/dialog_trigger

var hole_in_one: Array[bool] = [false, false, false, false]


func _ready() -> void:
	super()
	#show_title._play(CurrentLevelData.Titles.The_Subterranean_Trial)
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


func _on_holo_1_body_entered(_body: Node2D) -> void:
	_check_hole(1)


func _on_holo_2_body_entered(_body: Node2D) -> void:
	_check_hole(2)


func _on_holo_3_body_entered(_body: Node2D) -> void:
	_check_hole(3)


func _on_holo_4_body_entered(_body: Node2D) -> void:
	_check_hole(4)


func _check_hole(index: int) -> void:
	hole_in_one[index-1] = true

	for ind: int in range(0, 3):
		if hole_in_one[ind] == false:
			return
	print("desbloquear todo")


func _on_resect_jug_body_entered(body: Node2D) -> void:
	if body is AnimatableBody2D:
		body.reset()
