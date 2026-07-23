class_name Level3 extends Resource

@export var is_killer_boss: bool = false
@export var doors: Dictionary = {
	"level_3_section_1_mechanical_door" : false,
	"level_3_section_1_mechanical_door2" : false,
	"level_3_section_1_mechanical_door3" : false,
	"level_3_section_1_mechanical_door4" : false,

	"level_3_section_2_mechanical_door" : false,
	"level_3_section_2_mechanical_door2" : false,
	"level_3_section_2_double_mechanical_door" : false,
	"level_3_section_2_double_mechanical_door2" : false,
	"level_3_section_2_escalator" : false,
	"level_3_section_2_escalator2" : false,

	"level_3_section_3_mechanical_door" : false,
	"level_3_section_3_mechanical_door2" : false,
	"level_3_section_3_mechanical_door3" : false,
	"level_3_section_3_mechanical_door4" : false,
	"level_3_section_3_mechanical_door5" : false,
	"level_3_section_3_mechanical_door6" : false,
	"level_3_section_3_mechanical_door7" : false,
	"level_3_section_3_mechanical_door8" : false,
}
@export var switches: Dictionary = {
}
@export var parchments: Dictionary = {
	"level_3_section_2_skeleton" : {
		"index": -1,
		"dialog_name": "",
		"is_take": false,
		"is_interject": false
	},
}
@export var goldens_scarabs: Array[String] = []
@export var objects: Array = []
@export var puzles: Dictionary = {
	"pizle_boss": { "on": false, "jug_position": {"jug1": null, "jug2": null, "jug3": null, "jug4": null } }
}
