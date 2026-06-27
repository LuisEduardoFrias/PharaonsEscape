extends SectionBase

@onready var platform: Array[TileMapLayer] = [
	$platform/platform/TileMapLayer,
	$platform/platform/TileMapLayer2,
	$platform/platform/TileMapLayer3
]

var random_val : int = 0

func _ready() -> void:
	super()
	change_platform()


func change_platform() -> void:
	var random: int = 0

	while random_val == random:
		random = (randi() % 3 + 1)

	for i in randi_range(1,3):
		var pf = platform[i]

		if (i + 1) != random:
			pf.collision_enabled= false
			pf.visible = false
			continue

		pf.collision_enabled= true
		pf.visible = true
