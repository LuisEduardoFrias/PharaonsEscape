shader_type canvas_item;

uniform float swirl_velocity : hint_range(0.0, 200.0) = 100.0;
uniform float distortion_power : hint_range(0.0, 5.0) = 3.0;
uniform float progress : hint_range(0.0, 1.0) = 0.0;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec2 uv = SCREEN_UV - vec2(0.5);
    float dist = length(uv);
    
    // 1. EL VÉRTICE (Rotación exponencial)
    float spiral = swirl_velocity * progress * pow(max(0.0, 1.0 - dist), distortion_power);
    float s = sin(spiral);
    float c = cos(spiral);
    
    vec2 rotated_uv = vec2(
        uv.x * c - uv.y * s,
        uv.x * s + uv.y * c
    );
    
    // 2. SUCCIÓN (Escalado agresivo)
    // A medida que progress sube, el factor de escala hace que la imagen se "estire" al centro
    float scale_factor = max(1.0 - (progress * 1.5), 0.001); // El 1.5 acelera la succión
    vec2 final_uv = (rotated_uv / scale_factor) + vec2(0.5);
    
    // 3. MUESTREO DE COLOR
    vec4 screen_color = texture(SCREEN_TEXTURE, final_uv);
    
    // 4. OSCURECIMIENTO ORGÁNICO (Vignette dinámico)
    // En lugar de un círculo sólido, oscurecemos los píxeles según su distancia
    // y según qué tan avanzado esté el progreso.
    float darkness = smoothstep(1.0 - progress, 0.2 - progress, dist);
    
    // Aplicamos el oscurecimiento al color original
    vec3 final_rgb = screen_color.rgb * darkness;
    
    // 5. COLAPSO FINAL
    // Si la UV se sale del rango o el progreso es muy alto, forzamos negro
    if (final_uv.x < 0.0 || final_uv.x > 1.0 || final_uv.y < 0.0 || final_uv.y > 1.0) {
        final_rgb = vec3(0.0);
    }

    COLOR = vec4(final_rgb, 1.0);
}
