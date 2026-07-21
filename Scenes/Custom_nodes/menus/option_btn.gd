@tool extends TextureButton

@onready var label: Label = $Label


@export var text_size: int = 22:
	set(val):
		text_size = val
		if not is_node_ready(): await ready
		label.add_theme_font_size_override("font_size", val)
@export var text: String = "Example Text":
	set(val):
		text = val
		if not is_node_ready(): await ready
		label.text = val


func _set(property: StringName, value: Variant) -> bool:
	if property == "disabled":
		if not is_node_ready(): await ready
		disabled = value
		label["theme_override_colors/font_color"] = Color("7a7a7aff") if value else Color("ffdea3")
		label["theme_override_colors/font_outline_color"] = Color("bfbfbfff") if value else  Color("a75f00")
		return true
	return false


func _on_mouse_entered() -> void:
	if not disabled:
		enter(true)


func _on_mouse_exited() -> void:
	enter(false)

func _on_button_down() -> void:
		enter(true)


func _on_button_up() -> void:
	if not disabled:
		enter(false)


func enter(is_enter: bool ) -> void:
	label["theme_override_colors/font_color"] = Color("f0b000ff") if is_enter else Color("ffdea3")
	label["theme_override_colors/font_outline_color"] = Color("572f00ff") if is_enter else  Color("a75f00")
	label.scale = Vector2(0.9, 0.9) if is_enter else Vector2(1.0, 1.0)
