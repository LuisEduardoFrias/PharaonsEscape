@tool extends TextureButton

@export var text: String = "Button":
	set(val):
		text = val
		$MarginContainer/Label.text = val
