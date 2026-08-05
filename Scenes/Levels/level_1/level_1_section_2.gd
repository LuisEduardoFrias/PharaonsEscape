extends SectionBase

@onready var escalator: Escalator = $platform/escalator
@onready var fascade: ColorRect = $platform/fascade
@onready var fascade2: ColorRect = $platform/fascade2
@onready var switch3: Area2D = $platform/switch3
@onready var secret_area: Area2D = $area/secret_hidden_show
@onready var aisle_area: Area2D = $area/aisle_hidden_show
@onready var on_platfrom: Area2D = $area/is_in_bridge
@onready var secret: TileMapLayer = $secret
@onready var coli_lv2_01: CollisionShape2D = $area/hit_spawner/coli_lv2_01
@onready var coli_lv2_02: CollisionShape2D = $area/hit_spawner/coli_lv2_02


var secret_show: bool = false
var coli2_aisle_area: CollisionShape2D
var coli1_aisle_area: CollisionShape2D

func _ready() -> void:
	super()
	secret.modulate = Color("transparent")
	coli2_aisle_area = aisle_area.get_child(1)
	coli1_aisle_area = aisle_area.get_child(0)


func _on_switch_3_switch(on: bool) -> void:
	if on: escalator_facade()


func _on_fascade_show_body_entered(body: Node2D) -> void:
	if body is Player: escalator_facade(false)


func escalator_facade(active: bool = true) -> void:
	if active: escalator._open()
	else: escalator._close()
	if not active: switch3.active = false
	(fascade.get_child(0) as TileMapLayer).collision_enabled = !active

	var tw: Tween = create_tween()
	tw.tween_property(fascade, ^"modulate",
	Color("transparent") if active else Color("white") , 1.0)


func _on_secret_hidden_show_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, local_shape_index: int) -> void:
	if body is Player:
		if (local_shape_index in [2, 3] and secret_show) or local_shape_index in [0, 1]:
			var val = true if local_shape_index in [0, 1] else false
			secret_area.get_child(0).set_deferred("disabled", val)
			secret_area.get_child(1).set_deferred("disabled", val)

			var tw: Tween = create_tween()
			secret_show = !secret_show

			tw.tween_property(secret, ^"modulate",
			Color("transparent") if !secret_show else Color("white") , 1.0)


func _on_aisle_hidden_show_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, local_shape_index: int) -> void:
	if body is Player:
		coli2_aisle_area.set_deferred("disabled",  local_shape_index == 1)
		coli1_aisle_area.set_deferred("disabled",  local_shape_index == 0)
		var tw: Tween = create_tween()
		tw.tween_property(fascade2, ^"modulate", Color("transparent") if !coli1_aisle_area.disabled else Color("white") , 1.0)


func _on_bridge_is_jumping(on: bool) -> void:
	coli_lv2_01.set_deferred(&"disabled", on)
	coli_lv2_02.set_deferred(&"disabled", on)
	on_platfrom.set_deferred(&"monitoring", !on)
