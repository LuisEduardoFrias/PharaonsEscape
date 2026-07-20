extends Control

## Nodo que contiene las imágenes
@onready var texture_node: TextureRect = $container/hbc/pictures/texture

## Ruta de la escena final
@export_file("*.tscn") var next_scene_path: String

## Rutas de las imágenes de la historia
var path_pictures: Array[String] = [
	"res://Textures/History/H_1.png",
	"res://Textures/History/H_2.png",
	"res://Textures/History/H_3.png",
	"res://Textures/History/H_4.png",
	"res://Textures/History/H_5.png",
	"res://Textures/History/H_6.png",
	"res://Textures/History/H_7.png",
]

## Referencias a los labels de la interfaz
@onready var labels: Array[Label] = [
	$container/hbc/labels/Label1,
	$container/hbc/labels/Label2,
	$container/hbc/labels/Label3,
	$container/hbc/labels/Label4,
	$container/hbc/labels/Label5,
	$container/hbc/labels/Label6,
	$container/hbc/labels/Label7
]

@onready var next_button: Button = $container/hbc/labels/panel_btn/next_btn

var current_index: int = 0
var is_transitioning: bool = false

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color("000000ff"))

	for i: int in range(1, labels.size()):
		labels[i].hide()

	if labels.size() > 0:
		labels[0].modulate = Color(1, 1, 1, 1)
		_update_image(0)

	next_button.pressed.connect(on_next_button_pressed)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		_on_skip_btn_pressed()
		return

	var actions: Array[StringName] = [&"ui_accept", &"ui_left", &"ui_right", &"ui_up", &"ui_down"]
	for action: StringName in actions:
		if event.is_action_pressed(action):
			on_next_button_pressed()
			get_viewport().set_input_as_handled()
			break


## Cambia la imagen del nodo TextureRect
## @param index: Índice de la imagen a cargar
func _update_image(index: int) -> void:
	if index < path_pictures.size():
		var new_tex: Texture2D = load(path_pictures[index]) as Texture2D
		if new_tex:
			texture_node.texture = new_tex


func on_next_button_pressed() -> void:
	if is_transitioning:
		return

	is_transitioning = true

	if current_index < labels.size() - 1:
		var current_label: Label = labels[current_index]
		var next_label: Label = labels[current_index + 1]

		var fade_tween: Tween = create_tween()
		fade_tween.set_parallel(true)

		fade_tween.tween_property(current_label, "modulate:a", 0.0, 1.5)

		fade_tween.tween_property(texture_node, "modulate:a", 0.0, 1.25)

		fade_tween.chain().tween_callback(func() -> void:
			current_label.hide()
			current_index += 1
			_update_image(current_index)
			next_label.show()
			next_label.modulate.a = 0.0
		)

		fade_tween.tween_property(texture_node, "modulate:a", 1.0, 1.25)
		fade_tween.tween_property(next_label, "modulate:a", 1.0, 1.5)

		fade_tween.finished.connect(func() -> void:
			is_transitioning = false
		)
	else:
		_on_skip_btn_pressed()


func _on_skip_btn_pressed() -> void:
	get_tree().change_scene_to_file(next_scene_path)
	'''Global.trigger_screen_transition(func() -> void:

	)'''
