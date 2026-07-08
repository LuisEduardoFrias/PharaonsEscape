extends SectionBase

@onready var door1: MechanicalDoor = $doors/mechanical_door
@onready var door2: MechanicalDoor = $doors/mechanical_door2


func _ready() -> void:
	super()
	Global.check_door(LevelsData.Levels.LEVEL3, name, door1)
	Global.check_door(LevelsData.Levels.LEVEL3, name, door2)


func _on_switch_switch(_on: bool) -> void:
	Global.save_open_door(LevelsData.Levels.LEVEL3, name, door1)
