extends Node2D
class_name World

@onready var level_container: Node2D = $LevelContainer
@onready var player: CharacterBody2D = $Player
@onready var hud: Control = $CanvasLayer/HUD


func _ready() -> void:
	setup_world()


## Instancia la escena del nivel actual basándose en los datos del AutoLoad Global
## y posiciona al jugador en las coordenadas correspondientes.
func setup_world() -> void:
	var target_level_path: String = ""#Global.data.current_level

	if not ResourceLoader.exists(target_level_path):
		push_error("World Error: The level scene path does not exist: " + target_level_path)
		return

	var level_resource = load(target_level_path)
	var level_instance = level_resource.instantiate()
	level_container.add_child(level_instance)

	player.global_position = Global.data.player_stats.global_position

	if level_instance.has_method("initialize_level"):
		level_instance.initialize_level()

	if hud.has_method("update_hud"):
		hud.update_hud(Global.data.player_stats.health, Global.data.player_stats.energy)
