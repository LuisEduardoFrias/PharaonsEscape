extends Node2D

@onready var dialogue_trigger: DialogTrigger = $dialogue_trigger
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

@export var dialog_resouce: DialogueResource:
	set(val):
		dialog_resouce = val
		if not is_node_ready(): await ready
		dialogue_trigger.dialog_resouce = val


func _ready() -> void:
	dialogue_trigger.data.set("_save_papyrus", _save_papyrus)
	dialogue_trigger.data.set("_release_parchment", _release_parchment)
	Global.check_parchment(LevelsData.Levels.LEVEL3, owner.name, self)



func _save_papyrus() -> void:
	Global.save_parchment(LevelsData.Levels.LEVEL3, owner.name, self, true)


func _release_parchment() -> void:
	Global.save_parchment(LevelsData.Levels.LEVEL3, owner.name, self, false)
