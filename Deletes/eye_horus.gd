# EJE HORUS STATE
extends StateBase

func enter(_data: Dictionary = {}) -> void:
	super()
	actor.current_state = Player.States.IDLE

	var te: Tween = create_tween()
	var eye_horus: Sprite2D = $eye_of_horus/sprite
	is_eye_horus_enable = !is_eye_horus_enable
	te.tween_property(eye_horus, "texture:fill_to", \
	Vector2(1.0, 0.0) if is_eye_horus_enable else Vector2(0.5, 0.49), 2.0)

func update(_delta: float) -> void:
	pass


func input(_event: InputEvent) -> void:
	pass
