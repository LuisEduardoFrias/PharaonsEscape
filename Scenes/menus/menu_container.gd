extends Control

var main: String = "res://Scenes/menus/main_menu.tscn"
var select: String = "res://Scenes/menus/menu_selection_game.tscn"

func _ready() -> void:
	_change_escene(main)


func _change_escene(path: String) -> void:
	var pocked: PackedScene = load(path)
	var instance = pocked.instantiate()
	instance.changen.connect(_change_escene)
	var child = get_child(1)
	if child: remove_child(child)
	add_child(instance)
