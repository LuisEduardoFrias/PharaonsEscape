@tool extends TextureButton

@onready var label: Label = $Label

@export var text: String = "Example Text":
	set(val):
		text = val
		if not is_node_ready(): await ready
		label.text = val


func _on_mouse_entered() -> void:
	label["theme_override_colors/font_color"] = Color("f0b000ff")
	label["theme_override_colors/font_outline_color"] = Color("572f00ff")
	label.scale = Vector2(0.9, 0.9)


func _on_mouse_exited() -> void:
	label["theme_override_colors/font_color"] = Color("ffdea3")
	label["theme_override_colors/font_outline_color"] = Color("a75f00")
	label.scale = Vector2(1.0, 1.0)

func _on_button_down() -> void:
	label.scale = Vector2(0.9, 0.9)


func _on_button_up() -> void:
	label.scale = Vector2(1.0, 1.0)
