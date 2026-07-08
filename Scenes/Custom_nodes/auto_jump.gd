extends Area2D

var player: Player = null
var time_btn_press: float = 0.0

enum Dir { TOP, RIGHT, DOWN, LEFT }

@export var direction: Dir = Dir.DOWN

func _ready() -> void:
	body_entered.connect(_body_entered)
	body_exited.connect(_body_exited)


func _body_entered(body: Node) -> void:
	if body is Player:
		player = body


func _body_exited(body: Node) -> void:
	if body is Player:
		player = null


func _physics_process(delta: float) -> void:
	if player and !player.is_control_off :
		var text_btn = "ui_" + (Dir.keys()[direction]).to_lower()

		if Input.is_action_pressed(text_btn):
			time_btn_press += delta
		else: time_btn_press = 0.0

		if time_btn_press >= 0.3:
			time_btn_press = 0.0

			var pj: Player = player
			pj.collision_mask = 0
			pj.ray.collision_mask = 0

			pj._input_physics_off(true)
			pj.state_machine._on_child_transition(AnimationStateMachine.States.JUMP)

			await Util.timerout(0.5)
			pj.ray.collision_mask = 1
			pj.collision_mask = 1
