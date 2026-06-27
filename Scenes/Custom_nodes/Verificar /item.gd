extends Node2D

@onready var audio: AudioStreamPlayer2D = $audio_stream_player

@export var item_type: ItemsData.ItemType
@export var is_incremental: bool = false
@export var level_owner: LevelsData.Levels


func _ready() -> void:
	if Global.data.items.get(ItemsData.item_to_str(item_type)) and !is_incremental:
		queue_free()
	elif is_incremental:
		var goldens_scarabs: Array[String] = Global.data.levels.get(LevelsData.level_to_str(level_owner)).goldens_scarabs
		for gs in goldens_scarabs:
			if gs == name:
				queue_free()


func _on_area_body_entered(body: Node2D) -> void:
	if body is Player:
		audio.play()
		Global.add_item(item_type)
		if is_incremental: Global.add_incremental_item_code(level_owner, name)
		queue_free()
