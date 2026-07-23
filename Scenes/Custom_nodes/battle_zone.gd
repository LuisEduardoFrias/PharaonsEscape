extends Area2D

signal battle_finished

@export var escalators: Array[Escalator] = []
@export var Doors: Array[MechanicalDoor] = []
@export var enemics: Array[Enemy] = []

var count_enemic: int = 0

func _ready() -> void:
	count_enemic = enemics.size()
	body_entered.connect(_body_entered)


func _body_entered(body: Node2D) -> void:
	if body is Player:
		set_deferred("monitoring", false)
		close_doors()

		for enemic:Entity in enemics:
			enemic.is_dead.connect(enemic_dead)
			enemic.appearance()


func enemic_dead() -> void:
	count_enemic -= 1

	if count_enemic == 0:
		open_doors()
		battle_finished.emit()


func open_doors() -> void:
	for door in Doors:
		if door.get_meta("open"):
			Global.save_open_door(LevelsData.Levels.LEVEL3, owner.name, door)
	for escalator in escalators:
		if escalator.get_meta("open"): escalator._open()


func close_doors() -> void:
	for door in Doors:
		door._close()
	for escalator in escalators:
		escalator._close()
