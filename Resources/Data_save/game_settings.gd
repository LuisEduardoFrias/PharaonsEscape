class_name GameSettings extends Resource

enum DifficultyType { NORMAL, NOWAYBACK } #Normal / Sin Retorno
enum Code_Trans { EN, ES }

@export var difficulty: DifficultyType = DifficultyType.NORMAL
@export var languaje: Code_Trans = Code_Trans.EN
@export var audio_vol: float = 60.0
@export var sfx_vol: float = 60.0
@export var audio_on: bool = false
@export var sfx_on: bool = false
