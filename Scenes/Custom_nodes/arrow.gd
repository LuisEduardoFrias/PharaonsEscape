extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $animated
@onready var arrow: CharacterBody2D = $CharacterBody2D
@export var speed: int = 300
@export var direction: Vector2 = Vector2.DOWN
@export var damage: float = 20.0


func _ready() -> void:
	match direction:
		Vector2.UP:
			scale = Vector2(1.0, -1.0)
			rotation_degrees = 0.0
		Vector2.RIGHT:
			scale = Vector2(1.0, 1.0)
			rotation_degrees = -90.0
		Vector2.DOWN:
			scale = Vector2(1.0, 1.0)
			rotation_degrees = 0.0
		Vector2.LEFT:
			scale = Vector2(1.0, 1.0)
			rotation_degrees = -90.0


func _physics_process(_delta: float) -> void:
	velocity = direction * speed
	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player or body is TileMapLayer:
		anim.pause()
		if body.has_method("hurt"):
			body.hurt(damage)
		var tw: Tween = create_tween()
		tw.tween_property(self, ^"modulate", Color(0.0, 0.0, 0.0, 0.0), 1.0)
		tw.tween_callback(func()-> void: queue_free())
