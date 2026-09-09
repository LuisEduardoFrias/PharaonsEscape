@tool
extends Node

@export_file("*.png") var path: String

func _ready() -> void:
	if path.is_empty():
		print("Asigna la ruta de la imagen en el Inspector.")
		return

	var tex = load(path) as Texture2D
	if not tex:
		print("No se encontró la imagen.")
		return

	# Extraemos la imagen limpia
	var img = tex.get_image()
	if img.is_compressed():
		img.decompress()
	img.convert(Image.FORMAT_RGBA8)

	var font = FontFile.new()

	var chars = ".,&$@#-+()*\"':;!?./=>ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"

	var columns = 10
	var rows = 9
	var char_w = img.get_width() / columns
	var char_h = img.get_height() / rows

	# Definimos el tamaño de referencia como 64px
	var font_size = Vector2i(64, 0)

	# Asignamos la imagen al atlas de la fuente
	font.set_texture_image(0, font_size, 0, img)
	font.set_cache_ascent(0, 64, 64)
	font.set_cache_descent(0, 64, 0)

	var col = 0
	var row = 0

	for i in range(chars.length()):
		var c = chars.unicode_at(i)
		# Calculamos el recorte en la textura original
		var rect = Rect2(col * char_w, row * char_h, char_w, char_h)

		# Mapeo a tamaño 64x64
		font.set_glyph_texture_idx(0, font_size, c, 0)
		font.set_glyph_uv_rect(0, font_size, c, rect)
		font.set_glyph_size(0, font_size, c, Vector2(64, 64))
		# Desplazamiento exacto para que NO se dibuje fuera del cuadro del Label
		font.set_glyph_offset(0, font_size, c, Vector2(0, -64))
		font.set_glyph_advance(0, 64, c, Vector2(64, 0))

		col += 1
		if col >= columns:
			col = 0
			row += 1

	var save_path = "res://addons/mi_fuente_pixel.tres"
	var err = ResourceSaver.save(font, save_path)

	if err == OK:
		print("¡Fuente guardada exitosamente en ", save_path, "!")
	else:
		print("Error al guardar la fuente: ", err)
