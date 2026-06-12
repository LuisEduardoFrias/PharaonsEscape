class_name Data extends Resource

enum DifficultyType { NORMAL, NOWAYBACK } #Normal / Sin Retorno
enum Code_Trans { EN, ES }

@export var is_initial: bool = true
@export var difficulty: DifficultyType = DifficultyType.NORMAL
@export var languaje: Code_Trans = Code_Trans.EN
@export var items: ItemsData = ItemsData.new()
@export var current_level: CurrentLevelData = CurrentLevelData.new()
@export var player: PlayerData = PlayerData.new()
@export var skills: SkillsData = SkillsData.new()
@export var levels: LevelsData = LevelsData.new()
