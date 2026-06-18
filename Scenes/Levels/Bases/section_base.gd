extends Node2D
class_name SectionBase

@export var melody: AudioStream

@onready var player: Player
@onready var dead_black_screen: ColorRect
@onready var lower_level := $lower_level
@onready var background := $background
@onready var middleground := $midground
@onready var foreground:= $foreground
@onready var change_scene_screen: ColorRect = $CanvasLayer/change_scene_screen

signal spawner_ready

var world: World = null
var is_spawner_ready: bool = false:
	set(val):
		is_spawner_ready = val
		spawner_ready.emit()


func _ready() -> void:
	player = Util._find_player()
	world = Util._find_owner()
	$Sprite2D.visible = false
	RenderingServer.set_default_clear_color(Color("350005FF"))

	if SceneLoader.player_direction == Vector2.ZERO:
		change_scene_screen.transition_out(0.0)

		await Util.timerout(1.0)
		change_scene_screen.transition_in(4.0)
