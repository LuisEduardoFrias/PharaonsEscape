extends BaseEnemic

@onready var ray : RayCast2D = $raycast

var plugin: PlugingEnemic = null
var walking_time: SceneTreeTimer = null
var must_rotate: bool = false
var idle_timer: SceneTreeTimer

func _ready() -> void:
	super()
	$sprite.material = $sprite.material.duplicate()
	set_physics_process(false)
	speed = 4000
	current_direction = direc_to_vt2(Direction.LEFT)
	change_state(States.STATIC)


func _physics_process(delta: float) -> void:
	match current_state:
		States.WALKING: walking(delta)


func idle() -> void:
	var time: int = randi_range(1, 3)
	$Anim.play("idle")
	idle_timer = get_tree().create_timer(time)
	idle_timer.timeout.connect(idle_change, CONNECT_ONE_SHOT)


func idle_change() -> void:
	change_state(States.WALK)


func walk() -> void:
	var probability: int = randi_range(1, 6)
	if probability > 3 or must_rotate:
		match current_direction:
			Vector2.RIGHT, Vector2.LEFT: $sprite.flip_h = !$sprite.flip_h
			Vector2.UP, Vector2.DOWN: $sprite.flip_v = !$sprite.flip_v
		current_direction = current_direction * -1
		ray.target_position = ray.target_position * -1
		ray.force_raycast_update()
		must_rotate = false

	if is_player_in_zone_detect and randf_range(0, 5) >= 0 :
		is_player_in_zone_detect = false
		change_state(States.PERSECUTION)
		return
	elif is_player_in_zone_attack:
		is_player_in_zone_attack = false
		change_state(States.ATTACK)
		return

	if not walking_time :
		walking_time = get_tree().create_timer(randi_range(2,3))
		walking_time.timeout.connect(state_to_idle, CONNECT_ONE_SHOT)

	$Anim.play("walk")
	set_physics_process(true)
	change_state(States.WALKING)


func walking(delta: float) -> void:
	if ray.is_colliding():
		if walking_time and walking_time.timeout.is_connected(state_to_idle):
			walking_time.timeout.disconnect(state_to_idle)
			walking_time = null
			must_rotate = true
		set_physics_process(false)
		change_state(States.IDLE)
	else:
		velocity = current_direction * (speed * delta)
		velocity.normalized()
		move_and_slide()


func state_to_idle() -> void:
	change_state(States.IDLE)


func appear() -> void:
	$sprite.visible = true
	var tw :Tween= create_tween()
	tw.tween_property($sprite, "material:shader_parameter/progress", 0.0, 2.0)
	tw.tween_property($sprite, "material:shader_parameter/black_amount", 0.0 , 1.0)
	tw.tween_callback(func () -> void: change_state(States.WALK))


func change_state(state: States) -> void:
	if current_state == States.DEATH:
		return

	#print("Change_State: ", States.keys()[state])
	if plugin:
		plugin.end()
		plugin = null

	current_state = state

	match state:
		States.DEATH:
			if idle_timer and idle_timer.timeout.is_connected(idle_change):
				idle_timer.timeout.disconnect(idle_change)
				idle_timer = null
			if walking_time and walking_time.timeout.is_connected(state_to_idle):
				walking_time.timeout.disconnect(state_to_idle)
				walking_time = null
			set_physics_process(false)
			dead.emit()
			$Anim.play("death")
			await $Anim.animation_finished
			await get_tree().create_timer(0.5).timeout
			var tw:Tween = create_tween()
			tw.tween_property($sprite, "material:shader_parameter/black_amount", 1.0 , 1.0)
			tw.tween_property($sprite, "material:shader_parameter/progress", 1.0, 2.0)
			tw.tween_callback(func () -> void: call_deferred("queue_free"))

		States.IDLE: idle()
		States.WALK: walk()
		States.PERSECUTION:
			plugin = $detect_the_player
			$Anim.play("walk")
		States.ATTACK:
			plugin = $attack_the_player
			$Anim.play("attack")


	if plugin : plugin.init()
