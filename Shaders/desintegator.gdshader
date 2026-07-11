shader_type canvas_item;

uniform float black_amount : hint_range(0.0, 1.0) = 0.0;
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform float particle_size : hint_range(1.0, 10.0) = 1.0;
uniform float lift_strength : hint_range(0.0, 2.0) = 0.5;

varying float rel_y; // Variable para calcular la posición real dentro del frame

void vertex() {
	// Calculamos la posición vertical relativa al frame actual
	// Esto hace que el 0.0 sea siempre la cabeza del frame actual y 1.0 los pies
	rel_y = UV.y;
}

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	// Usamos AT_LIGHT_PASS o un truco de escalado para ignorar el atlas
	// En Godot, para fragmentos de Spritesheet, el UV ya viene normalizado al frame
	// si usamos la configuración correcta.
	
	vec2 tex_size = vec2(textureSize(TEXTURE, 0));
	vec2 size = tex_size / particle_size;
	vec2 grid_uv = floor(UV * size) / size;
	
	float p_id = hash(grid_uv);
	
	// --- LA CLAVE ---
	// Usamos fract(UV.y * 16.0) para que el shader crea que el frame mide de 0 a 1
	// (Cambiamos el 16.0 por tu numero de Vframes)
	float local_y = fract(UV.y * 16.0);
	
	float lift = 0.0;
	float alpha_val = 1.0;
	
	if (local_y < progress) {
		lift = (progress - local_y) * lift_strength * (1.0 + p_id);
		// Ajustamos el desvanecimiento para que sea más lento y se aprecie
		alpha_val = clamp(1.0 - (lift * 2.0), 0.0, 1.0);
	}
	
	// Movimiento de partículas
	vec2 target_uv = vec2(UV.x, UV.y - (lift / 16.0)); // Dividimos lift por vframes
	
	vec4 tex = texture(TEXTURE, target_uv);
	
	// Aplicar color negro
	tex.rgb = mix(tex.rgb, vec3(0.0), black_amount);
	
	// Máscara de partículas precisa
	if (local_y < progress) {
		if (p_id < 0.4) {
			discard;
		}
		tex.a *= alpha_val;
	}
	
	COLOR = tex;
}
