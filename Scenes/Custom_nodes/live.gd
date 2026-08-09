extends MarginContainer

@onready var live1: TextureRect = $panel/TextureRect/MarginContainer/VBoxContainer/HBoxContainer2/heart
@onready var live2: TextureRect = $panel/TextureRect/MarginContainer/VBoxContainer/HBoxContainer2/heart2
@onready var live3: TextureRect = $panel/TextureRect/MarginContainer/VBoxContainer/HBoxContainer2/heart3


func _ready() -> void:
	Global.player_data.hurt.connect(hurt)
	init_live()
	live1.scale = Vector2(0.0, 0.0)
	live2.scale = Vector2(0.0, 0.0)
	live3.scale = Vector2(0.0, 0.0)


func init_live() -> void:
	var tw: Tween = create_tween()
	match Global.player_data.current_live:
		1:
			tw.tween_property(live1, ^"scale", 1.0, 1.0)
			live1._hurt_1()
		2:
			tw.tween_property(live1, ^"scale", 1.0, 1.0)
			live1._retore()
		3:
			tw.tween_property(live2, ^"scale", 1.0, 1.0)
			live2._hurt_1()
		4:
			tw.tween_property(live2, ^"scale", 1.0, 1.0)
			live2._retore()
		5:
			tw.tween_property(live3, ^"scale", 1.0, 1.0)
			live3._hurt_1()
		6:
			tw.tween_property(live3, ^"scale", 1.0, 1.0)
			live3._retore()


func hurt(_damage: int) -> void:
	match Global.player_data.current_live:
		1: live1._hurt_1()
		2: live1.de()
		3: pass
		4: pass
		5: pass
		6: pass
