class_name CurrentLevelData extends Resource

enum Direction { NORTH, SOUTH, EAST, WEST }
enum Titles {
	TheDescendingPassage,
	TheGrandGallery,
	TheKingsChamber,
	TheGoldenPyramidion,
	TheDarkZone
}

@export var direction: Direction = Direction.NORTH
@export var level: Titles = Titles.TheKingsChamber
#@export var section: String = "res://Scenes/testing_ground.tscn"
@export var section: String = "res://Scenes/levels/level_3.tscn"
