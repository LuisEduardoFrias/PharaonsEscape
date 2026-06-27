extends Node2D

enum Button_type { ACTION_ONE, ACTION_TWO, ACTION_THREE, ACTION_FOUR, ACTION_RESET, ACTION_UP, ACTION_RIGHT, ACTION_DOWN, ACTION_LEFT, ACTION_W, ACTION_S, ACTION_D, ACTION_A, ACTION_H, ACTION_J, ACTION_K, ACTION_SPACE, ACTION_ENTER }
enum Desktop_btn_type { ACTION_W, ACTION_S, ACTION_D, ACTION_A, ACTION_H, ACTION_J, ACTION_K, ACTION_SPACE, ACTION_ENTER }

@export var show_btn: Button_type = Button_type.ACTION_ONE


func _ready() -> void:
	visible = false
	$AnimationPlayer.play(button_per_device(show_btn))


func change_btn(btn: Button_type) -> void:
	$AnimationPlayer.play(button_per_device(btn))


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_action_1"):
		visible = false


func button_per_device(btn: Button_type) -> String:
	var current_os: StringName = OS.get_name()
	var is_mobile_platform: bool = current_os == &"Android" or current_os == &"iOS"
	var return_value:String


	if is_mobile_platform:
		return_value = Button_type.keys()[btn]
	else :
		match btn:
			Button_type.ACTION_ONE:
				return_value = Desktop_btn_type.keys()[Desktop_btn_type.ACTION_H]
			Button_type.ACTION_TWO:
				return_value = Desktop_btn_type.keys()[Desktop_btn_type.ACTION_J]
			Button_type.ACTION_THREE:
				return_value = Desktop_btn_type.keys()[Desktop_btn_type.ACTION_K]
			Button_type.ACTION_FOUR:
				return_value = Desktop_btn_type.keys()[Desktop_btn_type.ACTION_SPACE]
			Button_type.ACTION_UP:
				return_value = Desktop_btn_type.keys()[Desktop_btn_type.ACTION_W]
			Button_type.ACTION_RIGHT:
				return_value = Desktop_btn_type.keys()[Desktop_btn_type.ACTION_D]
			Button_type.ACTION_DOWN:
				return_value = Desktop_btn_type.keys()[Desktop_btn_type.ACTION_S]
			Button_type.ACTION_LEFT:
				return_value = Desktop_btn_type.keys()[Desktop_btn_type.ACTION_A]
			Button_type.ACTION_RESET:
				return_value = Desktop_btn_type.keys()[Desktop_btn_type.ACTION_ENTER]
			_:
				return_value = "none"

	return return_value.to_lower()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		visible = true


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		visible = false
