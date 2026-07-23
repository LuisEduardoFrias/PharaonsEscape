extends SectionBase

@onready var door1: MechanicalDoor = $doors/mechanical_door
@onready var door2: MechanicalDoor = $doors/mechanical_door2
@onready var door3: MechanicalDoor = $doors/mechanical_door3
@onready var door4: MechanicalDoor = $doors/mechanical_door4
@onready var door5: MechanicalDoor = $doors/mechanical_door5
@onready var door6: MechanicalDoor = $doors/mechanical_door6
@onready var door7: MechanicalDoor = $doors/mechanical_door7
@onready var door8: MechanicalDoor = $doors/mechanical_door8

@onready var btn1: FloorButton = $objs/floor_button
@onready var btn2: FloorButton = $objs/floor_button2

@onready var battle_zone: Area2D = $platform/battle_zone3
@onready var camera1: Camera2D = $custom_camera
@onready var camera2: Camera2D = $objs/Camera2D
@onready var camera3: Camera2D = $objs/Camera2D2

@onready var generador1: Node2D = $tramps/arrow_generator9
@onready var generador2: Node2D = $tramps/arrow_generator10

var TIME_TIMER: float = 10.0
var timer: float = 0.0


func _ready() -> void:
	super()
	set_process(false)
	door1.position.x -= 128.0
	Global.check_door(LevelsData.Levels.LEVEL3, name, door1)
	Global.check_door(LevelsData.Levels.LEVEL3, name, door2)
	Global.check_door(LevelsData.Levels.LEVEL3, name, door3)
	Global.check_door(LevelsData.Levels.LEVEL3, name, door4)
	Global.check_door(LevelsData.Levels.LEVEL3, name, door5)
	Global.check_door(LevelsData.Levels.LEVEL3, name, door6)
	Global.check_door(LevelsData.Levels.LEVEL3, name, door7)
	Global.check_door(LevelsData.Levels.LEVEL3, name, door8)


func _process(delta: float) -> void:
	timer += delta

	if timer >= TIME_TIMER:
		timer = 0.0
		if not btn1.is_active or not btn2.is_active:
			btn1._desactive()
			btn2._desactive()
		else:
			set_process(false)
			Util.temporarily_switch_camera(camera1, camera2, func() -> void:
				Global.save_open_door(LevelsData.Levels.LEVEL3, name, door3)
				Global.save_open_door(LevelsData.Levels.LEVEL3, name, door7)
			)


func _on_battle_zone_2_body_entered(body: Node2D) -> void:
	if body is Player:
		door4.invert = true


func _on_floor_lever_is_activated(on: bool) -> void:
	if on:
		Util.temporarily_switch_camera(camera1, camera3, func() -> void:
			Global.save_open_door(LevelsData.Levels.LEVEL3, name, door2)
		)


func _on_floor_lever_2_is_activated(on: bool) -> void:
	if on:
		Util.temporarily_switch_camera(camera1, camera2, func() -> void:
			Global.save_open_door(LevelsData.Levels.LEVEL3, name, door6)
		)


func _on_floor_button_is_activated() -> void:
	set_process(true)


func _on_floor_button_2_is_activated() -> void:
	generador1.enabled = false
	generador2.enabled = false


func _on_floor_button_3_is_activated() -> void:
	Global.save_open_door(LevelsData.Levels.LEVEL3, name, door1)
	Global.section_2_active_door = true
	battle_zone.monitoring = true
