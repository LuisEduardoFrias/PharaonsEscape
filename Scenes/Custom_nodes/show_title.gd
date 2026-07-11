@tool extends Control

@onready var label: Label = $TextureRect/Label

@export var title : CurrentLevelData.Titles = CurrentLevelData.Titles.The_Grand_Gallery:
	set(v):
		title = v
		_refresh_label()


func _ready() -> void:
	_refresh_label()


func _play(_title: CurrentLevelData.Titles) -> void:
	title = _title
	$AnimationPlayer.play("show_title")


func _refresh_label() -> void:
	if not is_node_ready(): await ready
	label.text = tr(CurrentLevelData.titles_to_str(title))
	accessibility_name = label.text
	accessibility_description = label.text
