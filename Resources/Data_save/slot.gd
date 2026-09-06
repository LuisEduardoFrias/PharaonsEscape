class_name Slot extends Resource

@export var slot_id: int = 0
@export var is_slot_empty: bool = true
@export var data_game_path: String = ""

@export var time_gaming: int = 0
@export var current_live: int = 6
@export var current_potions: Array[Horney] = []
@export var bugs: int = 0
@export var level_name: String = CurrentLevelData.titles_to_str(CurrentLevelData.Titles.The_Grand_Gallery)
