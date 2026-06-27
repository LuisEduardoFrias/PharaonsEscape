extends Enemy

@onready var anim:AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	super()
	anim.animation_finished.connect(func () -> void:
		if anim.animation != "idle": anim.play(&"idle")
	)


var rd: int = 2

func animation_effect() -> void:
	rd = (rd - 1 + (randi() % 2 + 1)) % 3 + 1

	match rd:
		1: anim.play(&"hurt_1")
		2: anim.play(&"hurt_2")
		3: anim.play(&"hurt_3")
