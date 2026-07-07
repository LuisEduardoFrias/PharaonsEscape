@tool class_name AnimationStateMachine extends AnimationTree

@export var initial_state: StateBase
@export_dir var state_script_path: String

enum States { NONE__NOT_ADD, IDLE, WALK, JUMP, ROLL, SWORD_ATTACK, FALL, INTERACT }

var states_node: Dictionary = {}
var current_state: StateBase:
	set(val):
		current_state = val
		parameter = REPLACE_PARAMETER.replace("{state_name}", val.name)
var parameter : String
var playback: AnimationNodeStateMachinePlayback
var animation_name: StringName = ""

const REPLACE_PARAMETER = "parameters/{state_name}/BlendSpace2D/blend_position"


func _ready() -> void:
	playback = get("parameters/playback")
	await owner.ready

	for child: StateBase in get_children():
		states_node[child.name.to_lower()] = child
		child.change_state.connect(_on_child_transition)
		child.actor = owner as Entity

	if initial_state:
		set_current_state(initial_state)


func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		generate_states()
	if current_state: current_state.update(delta)


func _physics_process(delta: float) -> void:
	if current_state: current_state.physics_update(delta)


func _input(event: InputEvent) -> void:
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
		set(parameter, direction)


## Canbia el estado actual
func _on_child_transition(_new_state: States, data: Dictionary = {}) -> void:
	if _new_state == States.NONE__NOT_ADD:
		return

	var new_state: StateBase = states_node.get(states_to_str(_new_state))
	if !new_state or new_state == current_state:
		return

	if current_state:
		current_state.exit()

	set_current_state(new_state, data)


## Inicializa el nuevo estado
func set_current_state(new_state: StateBase, data: Dictionary = {}) -> void:
	current_state = new_state
	playback.travel(new_state.name)
	new_state.enter(data)


## Género los archivos de estado
func generate_states() -> void:
	if state_script_path == "":
		return

	if not DirAccess.dir_exists_absolute(state_script_path):
		DirAccess.make_dir_recursive_absolute(state_script_path)

	for key: String in States.keys():
		if !key.ends_with("__NOT_ADD"):
			var state_name: String = String(key).to_lower()
			var file_path: String = state_script_path.path_join(state_name + ".gd")

			if not FileAccess.file_exists(file_path):
				var file = FileAccess.open(file_path, FileAccess.WRITE)
				if file:
					var script_content = "# {name} STATE\nextends StateBase\n\nfunc enter(_data: Dictionary = {}) -> void:\n\tsuper()\n\n\n\nfunc physics_update(_delta: float) -> void:\n\tpass\n\n\nfunc input(_event: InputEvent) -> void:\n\tpass\n".format({"name": state_name.to_upper()})
					file.store_string(script_content)
					file.close()

					if Engine.is_editor_hint():
						EditorInterface.get_resource_filesystem().scan()

			if not has_node(state_name):
				var new_node: Node = Node.new()
				new_node.name = state_name

				var state_script = load(file_path)
				if state_script:
					new_node.set_script(state_script)

				add_child(new_node)

				if Engine.is_editor_hint():
					new_node.owner = get_tree().edited_scene_root


func _on_animation_finished(_anim_name: StringName) -> void:
	animation_name = playback.get_current_node()
	_on_child_transition(str_to_state(animation_name))
