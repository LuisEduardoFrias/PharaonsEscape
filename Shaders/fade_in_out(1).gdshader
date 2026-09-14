shader_type canvas_item;

// Captura lo que se renderiza en la pantalla detrás del nodo
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

// Control de Transición (0.0 = Pantalla limpia, 1.0 = Pantalla totalmente negra)
uniform float progress : hint_range(0.0, 1.0) = 0.0;

// Parámetros del Zoom Blur
uniform float blur_strength : hint_range(0.0, 1.0) = 0.4;
uniform vec2 blur_center = vec2(0.5, 0.5);

const int MAX_SAMPLES = 16;

void fragment() {
	vec2 uv = SCREEN_UV;

	if (progress <= 0.001) {
		// Pantalla normal limpia (transparente/sin efecto)
		COLOR = texture(screen_texture, uv);
	} else if (progress >= 0.999) {
		// Pantalla completamente negra
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	} else {
		// Procesamiento del Zoom Blur durante la transición
		float strength = progress * blur_strength;
		vec2 to_center = blur_center - uv;

		vec4 blurred = vec4(0.0);
		float total = 0.0;

		for (int i = 0; i < MAX_SAMPLES; i++) {
			float percent = float(i) / float(MAX_SAMPLES - 1);
			float weight = percent * (1.0 - percent) + 0.001;

			vec2 sample_uv = clamp(uv + to_center * percent * strength, vec2(0.0), vec2(1.0));
			
			blurred += texture(screen_texture, sample_uv) * weight;
			total += weight;
		}

		blurred /= total;

		// Mezcla el desfoque con negro a medida que 'progress' sube
		COLOR = mix(blurred, vec4(0.0, 0.0, 0.0, 1.0), progress);
	}
}
