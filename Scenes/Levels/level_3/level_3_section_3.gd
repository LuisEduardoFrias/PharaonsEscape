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
@onready var camera1: Camera2D = $Camera
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


func _process(delta: float) -> void:
	timer += delta

	if timer >= TIME_TIMER:
		timer = 0.0
		if not btn1.is_active or not btn2.is_active:
			btn1._desactive()
			btn2._desactive()
		else:
			set_process(false)
			camera1.enabled = false
			camera2.enabled = true
			await Util.timerout(1.0)
			door3._open()
			door7._open()
			await Util.timerout(3.0)
			camera2.enabled = false
			camera1.enabled = true


func _on_battle_zone_2_body_entered(body: Node2D) -> void:
	if body is Player:
		door4.invert = true


func _on_floor_lever_is_activated(on: bool) -> void:
	if on: door2._open()


func _on_floor_lever_2_is_activated(on: bool) -> void:
	if on: door6._open()


func _on_floor_button_is_activated() -> void:
	set_process(true)


func _on_floor_button_2_is_activated() -> void:
	generador1.enabled = false
	generador2.enabled = false


func _on_floor_button_3_is_activated() -> void:
	door1._open()
	battle_zone.monitoring = true
