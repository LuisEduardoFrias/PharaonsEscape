@tool
extends Control


@export var title : CurrentLevelData.Titles = CurrentLevelData.Titles.TheDescendingPassage:
	set(v):
		title = v
		# Usamos un nombre de función que no choque con Godot
		refresh_label()


func _ready() -> void:
	refresh_label()


func play() -> void:
	$AnimationPlayer.play("show_title")


func refresh_label() -> void:
	if not is_node_ready():
		await ready

	var label:Label = get_node_or_null("Sprite2D/Label")
	if label:
		label.text = title_to_str(title)


func title_to_str(title_val: CurrentLevelData.Titles) -> String:
	match title_val:
		CurrentLevelData.Titles.TheDescendingPassage: return "The Descending Passage"
		CurrentLevelData.Titles.TheGrandGallery:      return "The Grand Gallery"
		CurrentLevelData.Titles.TheKingsChamber:      return "The King's Chamber"
		CurrentLevelData.Titles.TheGoldenPyramidion:  return "The Golden Pyramidion"
		CurrentLevelData.Titles.TheDarkZone:          return "The Dark Zone"
		_:                          return "Unknown Level"
