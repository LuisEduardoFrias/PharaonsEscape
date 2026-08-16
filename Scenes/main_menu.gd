extends Control

@onready var vortex: CanvasLayer = $vortex_transition
@onready var anim: AnimationPlayer = %anim
@onready var panel_material: ShaderMaterial = %Panel.material as ShaderMaterial
@onready var main: VBoxContainer = %main
@onready var option: VBoxContainer = %options


func _ready() -> void:
	_hide_magic()
	anim.play(&"close")
	await vortex.transition_out(0.4)
	anim.play_backwards(&"close")
	await anim.animation_finished
	_show_magic()


func save_settings() -> void:
	SaveManager.save_game_settings()


func _on_start_btn_pressed() -> void:
	await  _hide_magic()
	anim.play(&"close")
	await anim.animation_finished
	await vortex.transition_in(0.4)
	get_tree().change_scene_to_file("res://Scenes/menu_selection_game.tscn")


func _on_options_btn_pressed() -> void:
	_option_change()


func _on_extra_btn_pressed() -> void:
	await  _hide_magic()
	anim.play(&"close")


func _on_contros_pressed() -> void:
	pass # Replace with function body.


func _on_audios_pressed() -> void:
	pass # Replace with function body.


func _on_back_pressed() -> void:
	_option_change(false)


func _option_change(is_options: bool = true) -> void:
	await _hide_magic()
	anim.play(&"close")
	await anim.animation_finished
	await Util.timerout(0.5)
	option.visible = is_options
	main.visible = !is_options
	anim.play_backwards(&"close")
	await anim.animation_finished
	_show_magic()


func _on_exit_btn_pressed() -> void:
	await  _hide_magic()
	anim.play(&"close")
	await anim.animation_finished
	await vortex.transition_in(0.4)
	get_tree().change_scene_to_file("res://Scenes/menu_selection_game.tscn")
	get_tree().quit()


func _hide_magic(duration: float = 1.0) -> Signal:
	var tween = create_tween()
	tween.tween_property(panel_material, "shader_parameter/progress", 1.0, duration)
	return tween.finished


func _show_magic(duration: float = 1.0) -> Signal:
	var tween = create_tween()
	tween.tween_property(panel_material, "shader_parameter/progress", 0.0, duration)
	return tween.finished
