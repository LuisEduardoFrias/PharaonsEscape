extends Camera2D

# Variable para rastrear si el usuario está arrastrando la pantalla
var arrastrando: bool = false

func _input(event: InputEvent) -> void:
	# Detectar cuando se presiona o suelta el clic izquierdo del mouse o el toque táctil
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			arrastrando = event.pressed

	elif event is InputEventScreenTouch:
		arrastrando = event.pressed

	# Si está arrastrando y se mueve el mouse/dedo, movemos la cámara
	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		if arrastrando:
			# Al restar el 'relative', la cámara se mueve en dirección "contraria" al arrastre,
			# dando el efecto natural de que estás "empujando" el mapa.
			# Multiplicamos por 'zoom' para que la velocidad de arrastre se mantenga constante si cambias el zoom.
			global_position -= event.relative * (1.0 / zoom.x)
