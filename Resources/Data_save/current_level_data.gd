#PLACEHOLDER_TO_REPLACE:res://Scenes/Levels/level_1/level_1_section_2.tscn

class_name CurrentLevelData extends Resource

enum Titles {
	The_Subterranean_Trial, #El Juicio Subterráneo
	The_Labyrinth_of_Sand, #El Laberinto de Arena
	The_Grand_Gallery, #La Gran Galería
	The_Scorched_Catacombs, #Las Catacumbas Quemadas
	The_Golden_Pyramidion, #El Piramidión Dorado
	The_Dark_Zone, #La zona de las sombras
	The_Flooded_Vault, #La Bóveda Inundada
}

@export var level_name: String = titles_to_str(Titles.The_Grand_Gallery)
@export var section: String = "res://Scenes/Levels/level_1/level_1_section_2.tscn"


static func titles_to_str(titles: Titles) -> String:
	match titles:
		Titles.The_Subterranean_Trial:
			return "The Subterranean Trial" #El Juicio Subterráneo
		Titles.The_Labyrinth_of_Sand:
			return "The Labyrinth of Sand" #El Laberinto de Arena
		Titles.The_Grand_Gallery:
			return "The Grand Gallery" #La Gran Galería
		Titles.The_Scorched_Catacombs:
			return "The Scorched Catacombs" #Las Catacumbas Quemadas
		Titles.The_Golden_Pyramidion:
			return "The Golden Pyramidion" #El Piramidión Dorado
		Titles.The_Dark_Zone:
			return "The Dark Zone" #La zona de las sombras
		Titles.The_Flooded_Vault:
			return "The Flooded Vault" #La Bóveda Inundada
		_:
			return "Unknown Level"
