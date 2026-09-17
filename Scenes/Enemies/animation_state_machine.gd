class_name AnimationEnemyStateMachine extends Node

@export var anim: AnimationPlayer
@export var default_state: EnemyState = null

enum States { NONE__NOT_ADD, IDLE, WALK, HURT, DEATH, ATTACK1, ATTACK2, ATTACK3, ATTCK4 }

var states_node: Dictionary = {}
var current_state: EnemyState
var animation_name: StringName = ""


func _ready() -> void:
	await owner.ready

	for child: EnemyState in get_children().filter(func(node: Node) -> bool: return node is EnemyState):
		states_node[child.name.to_lower()] = child
		child.change_state.connect(_on_child_transition)
		child.actor = (owner as EnemyBase)

	if default_state:
		set_current_state(default_state)


func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		if current_state: current_state.update(delta)


func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint():
		if current_state: current_state.physics_update(delta)


func _input(event: InputEvent) -> void:
	if not Engine.is_editor_hint():
		if current_state: current_state.input(event)


## retorna un valor del enumerado como string
func states_to_str(_state: States) -> String:
	return States.keys()[_state].to_lower()


## retorna un enumerador según el string
func str_to_state(name_:StringName) -> States:
	if States.has(name_.to_upper()):
		return States[name_.to_upper()]
	return States.NONE__NOT_ADD


## asigna parámetro a los estado para los movimientos
func animation_direction(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		if direction.x > 0: owner.sprite.flip_h = true
		elif direction.x < 0: owner.sprite.flip_h = false


func _cinematic(_new_state: States) -> void:
	anim.play(states_to_str(_new_state))


## Canbia el estado actual
func _on_child_transition(_new_state: States, data: Dictionary = {}) -> void:
	if _new_state == States.NONE__NOT_ADD:
		return

	var new_state: EnemyState = states_node.get(states_to_str(_new_state))
	if !new_state or new_state == current_state:
		return

	if current_state:
		current_state.exit()

	set_current_state(new_state, data)


## Inicializa el nuevo estado
func set_current_state(new_state: EnemyState, data: Dictionary = {}) -> void:
	current_state = new_state
	anim.play(new_state.name)
	new_state.enter(data)


func _on_animation_finished(_anim_name: StringName) -> void:
	animation_name = anim.current_animation.get_basename()
	_on_child_transition(str_to_state(animation_name))
