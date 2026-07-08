extends SectionBase

@onready var door1: MechanicalDoor = $doors/mechanical_door
@onready var door2: MechanicalDoor = $doors/mechanical_door2


func _ready() -> void:
	super()
	door2.opening = Global.active_door



func _on_switch_switch(_on: bool) -> void:
	door1._open()
