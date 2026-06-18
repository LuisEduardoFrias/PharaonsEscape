extends Node

# Arrastra aquí tu archivo .res desde el FileSystem
@export var anim_library: AnimationLibrary

func _ready() -> void:
	if not anim_library:
		print("Por favor, asigna la librería en el inspector")
		return

	var anim_names = anim_library.get_animation_list()

	for anim_name in anim_names:
		var anim = anim_library.get_animation(anim_name)
		# Buscamos pistas que controlen 'monitorable'
		for i in range(anim.get_track_count()):
			var path = anim.track_get_path(i)
			if "monitorable" in str(path):
				anim.remove_track(i)
				print("Pista eliminada en: ", anim_name)
				break # Salimos del loop de pistas para esta animación

	# CRUCIAL: Guardar los cambios en el archivo .res
	ResourceSaver.save(anim_library, anim_library.resource_path)
	print("Librería limpiada y guardada en disco.")
