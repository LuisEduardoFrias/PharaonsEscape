class_name Level3 extends Resource

@export var is_killer_boss: bool = false
@export var doors: Dictionary = {
	"ladder": false,
	"ladder2": false,
	"wall_gap_roll_2": false,
}
@export var goldens_scarabs: Array[String] = []
@export var objects: Array = []
@export var puzles: Dictionary = {
	"pizle_boss": { "on": false, "jug_position": {"jug1": null, "jug2": null, "jug3": null, "jug4": null } }
}
