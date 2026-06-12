class_name LevelsData extends Resource

enum Levels { LEVEL1, LEVEL2, LEVEL3, LEVEL4, LEVEL5, LEVEL6 }

static func level_to_str(level: Levels) -> String:
	return (Levels.keys()[level] as String).to_camel_case()


@export var level1: Level1 = Level1.new()
@export var level2: Level2 = Level2.new()
@export var level3: Level3 = Level3.new()
@export var level4: Level4 = Level4.new()
@export var level5: Level5 = Level5.new()
