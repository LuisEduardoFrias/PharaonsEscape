shader_type canvas_item;

// OBLIGATORIO: filter_linear_mipmap permite usar LOD reales de la pantalla
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;

// Parámetros parametrizables desde el Inspector / GDScript
uniform float blur_amount : hint_range(0.0, 10.0) = 4.0;
uniform float lod_level : hint_range(0.0, 5.0) = 2.5;
uniform vec4 mix_color : source_color = vec4(0.1, 0.1, 0.15, 0.4);
uniform float color_opacity : hint_range(0.0, 1.0) = 0.6;

void fragment() {
	vec2 screen_uv = SCREEN_UV;
	
	// Si blur_amount es 0, hacemos un muestreo limpio e inmediato
	if (blur_amount <= 0.01) {
		COLOR = texture(screen_texture, screen_uv);
	} else {
		// Tamaño de texel basado en la resolución de pantalla
		vec2 texel_size = SCREEN_PIXEL_SIZE * blur_amount;
		vec4 color_acc = vec4(0.0);
		float total_weight = 0.0;
		
		// Calculamos el nivel de mipmap dinámico según la intensidad requerida
		float current_lod = mix(0.0, lod_level, clamp(blur_amount / 5.0, 0.0, 1.0));

		// Kernel de dispersión en matriz de 5x5 con pesos aproximados
		for (float x = -2.0; x <= 2.0; x += 1.0) {
			for (float y = -2.0; y <= 2.0; y += 1.0) {
				// Peso gaussiano simplificado por distancia al centro
				float weight = 1.0 - (length(vec2(x, y)) / 3.0);
				weight = max(weight, 0.05);
				
				vec2 offset = vec2(x, y) * texel_size;
				
				// Muestreo usando textureLod aprovechando los mipmaps forzados
				color_acc += textureLod(screen_texture, screen_uv + offset, current_lod) * weight;
				total_weight += weight;
			}
		}

		// Normalización de color desenfocado
		vec4 blurred_color = color_acc / total_weight;
		
		// Aplicamos tinte de opacidad y color base para lograr el aspecto "cristal opaco"
		vec3 final_rgb = mix(blurred_color.rgb, mix_color.rgb, mix_color.a * color_opacity);
		
		COLOR = vec4(final_rgb, 1.0);
	}
}
