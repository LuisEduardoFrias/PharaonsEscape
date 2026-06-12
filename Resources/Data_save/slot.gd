class_name Slot extends Resource

@export var slot_id: String:
	set(val):
		slot_id = val
		data_game_path = 'save_pharaons_escape/' + val
@export var index_ui: int
@export var time_gaming: int = 0
@export var current_live: int = 6
@export var bugs: int = 0
@export var level_name: String = Global.get_level_name(CurrentLevelData.Titles.TheKingsChamber)
@export var data_game_path: String
