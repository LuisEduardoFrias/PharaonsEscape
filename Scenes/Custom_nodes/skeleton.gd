extends Node2D

@export var index_id: int = 0
@export var dialog_resouce: DialogueResource:
	set(val):
		$dialogue_trigger.dialog_resouce = val


var was_taken:= false

func _ready() -> void:
	pass
	'''if Global.data.items.parchments[index_id]:
		was_taken = true
		$AnimatedSprite2D.stop()'''

	$dialogue_trigger.data.set("_save_papyrus", _save_papyrus)


func _save_papyrus() -> void:
	#Global.save_parchment(index_id)
	was_taken = true
	$AnimatedSprite2D.stop()
