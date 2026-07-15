extends SectionBase

## Array de capas que actúan como plataformas en la sextends
@onready var platform: Array[TileMapLayer] = [
	$platform/platform/TileMapLayer,
	$platform/platform/TileMapLayer2,
	$platform/platform/TileMapLayer3
]

## Guarda el índice de la plataforma activa para evitar repetir la misma en el siguiente cambio.
var random_val: int = -1


func _ready() -> void:
	super()
	player.tile_hit_respawnd.connect(change_platform)
	change_platform()


## Selecciona una plataforma aleatoria distinta a la actual y actualiza el estado de todas.
func change_platform() -> void:
	var new_random: int = random_val

	while new_random == random_val:
		new_random = randi() % platform.size()

	random_val = new_random

	for i in platform.size():
		var pf: TileMapLayer = platform[i]
		var is_active: bool = (i == random_val)

		pf.collision_enabled = is_active
		pf.get_child(0).enabled = is_active
		pf.get_child(1).monitoring = is_active
		pf.visible = is_active
