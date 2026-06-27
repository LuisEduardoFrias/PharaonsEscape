@tool
extends ColorRect

@export_group("Configuración de Partículas")

@export var activar_particulas: bool = true:
	set(value):
		activar_particulas = value
		_actualizar_particulas()

@export var cantidad_particulas: int = 20:
	set(value):
		cantidad_particulas = value
		_actualizar_particulas()

@export var color_particulas: Color = Color(0.0, 0.0, 0.0, 0.6):
	set(value):
		color_particulas = value
		_actualizar_particulas()

@export var ancho_puerta: Vector2 = Vector2(32.0, 32.0)

@export var velocidad_particulas: float = 15.0:
	set(value):
		velocidad_particulas = value
		_actualizar_particulas()

func _ready() -> void:
	# En el ready aseguramos que se ejecute una vez al arrancar
	_actualizar_particulas()


func _set(property: StringName, value: Variant) -> bool:
	if property == "size":
		size = value
		ancho_puerta = size
		$GPUParticles2D.position = (ancho_puerta / 2)
		_actualizar_particulas()
	return false



func _actualizar_particulas() -> void:
	# Usamos find_child que es más seguro y robusto en modo @tool dentro del editor
	var particles = find_child("GPUParticles2D", false, false) as GPUParticles2D

	if not particles:
		return # Retorna silenciosamente si el editor aún está cargando el nodo hijo

	# Creamos o reutilizamos el material de proceso
	var mat = particles.process_material as ParticleProcessMaterial
	if not mat:
		mat = ParticleProcessMaterial.new()
		particles.process_material = mat

	# 1. Configurar Área de Emisión (Box)
	mat.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	mat.emission_box_extents = Vector3(ancho_puerta.x/2, ancho_puerta.y/2, ancho_puerta.x/2)


	# 2. Dirección (Hacia abajo en Y) y Dispersión
	mat.direction = Vector3(0.0, 1.0, 0.0)
	mat.spread = 15.0

	# 3. Apagar Gravedad por completo para evitar caídas raras en top-down
	mat.gravity = Vector3(0.0, 0.0, 0.0)

	# 4. VELOCIDAD (ID 0 directo de la API nativa)
	mat.set_param_min(ParticleProcessMaterial.PARAM_INITIAL_LINEAR_VELOCITY, velocidad_particulas - 5.0)
	mat.set_param_max(ParticleProcessMaterial.PARAM_INITIAL_LINEAR_VELOCITY, velocidad_particulas + 5.0)

	# 5. ESCALA (ID 5 directo para el tamaño del píxel)
	mat.set_param_min(ParticleProcessMaterial.PARAM_TANGENTIAL_ACCEL, 1.0)
	mat.set_param_max(ParticleProcessMaterial.PARAM_TANGENTIAL_ACCEL, 2.0)

	# 6. Gradiente de color dinámico (Fade in / Fade out)
	var gradient = Gradient.new()
	gradient.set_color(0, Color(color_particulas.r, color_particulas.g, color_particulas.b, 0.0))
	gradient.add_point(0.2, color_particulas)
	gradient.set_color(1, Color(color_particulas.r, color_particulas.g, color_particulas.b, 0.0))

	var grad_texture = GradientTexture1D.new()
	grad_texture.gradient = gradient
	mat.color_ramp = grad_texture

	# 7. Asignación al nodo GPUParticles2D hijo
	particles.amount = max(1, cantidad_particulas)
	particles.emitting = activar_particulas

	# Textura por defecto si no tiene ninguna asignada
	if particles.texture == null:
		particles.texture = PlaceholderTexture2D.new()
