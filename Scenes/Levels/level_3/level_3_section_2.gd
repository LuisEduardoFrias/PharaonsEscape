extends SectionBase

@onready var door1: MechanicalDoor = $doors/mechanical_door
@onready var door2: MechanicalDoor = $doors/mechanical_door2
@onready var door3: MechanicalDoor = $doors/mechanical_door3
@onready var door4: MechanicalDoor = $doors/mechanical_door4


func _ready() -> void:
	super()


func _on_switch_switch() -> void:
	door1._open()
	door2._open()
