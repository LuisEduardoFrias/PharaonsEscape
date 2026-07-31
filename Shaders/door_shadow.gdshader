shader_type canvas_item;

// Textura de ruido opcional para el efecto de neblina/humo
uniform sampler2D noise_texture : repeat_enable;
uniform vec4 portal_color : source_color = vec4(0.4, 0.1, 0.8, 1.0); // Púrpura oscuro / Sombras
uniform vec4 glow_color : source_color = vec4(0.8, 0.2, 1.0, 2.0);   // Brillo intenso (HDR)
uniform float noise_speed = 0.5;
uniform float vignette_strength : hint_range(0.0, 2.0) = 0.8;

void fragment() {
    // 1. Obtener el color original de tu animación
    vec4 orig_color = texture(TEXTURE, UV);
    
    // 2. Muestrear la textura de ruido moviéndose en diagonal (efecto humo)
    vec2 noise_uv = UV + vec2(TIME * noise_speed * 0.2, TIME * noise_speed * 0.1);
    float noise_val = texture(noise_texture, noise_uv).r;
    
    // 3. Crear una viñeta circular para dar sensación de túnel/profundidad
    vec2 center_uv = UV - vec2(0.5);
    float dist_from_center = length(center_uv);
    float vignette = smoothstep(0.5, 0.1, dist_from_center * vignette_strength);
    
    // 4. Combinar la neblina con la animación base y potenciar el brillo HDR
    vec3 final_rgb = mix(orig_color.rgb, portal_color.rgb, noise_val * 0.5);
    
    // Añadir resplandor en las zonas donde el ruido es más denso
    final_rgb += glow_color.rgb * pow(noise_val, 2.0) * orig_color.a;
    
    // Aplicar la viñeta para oscurecer el centro/fondo
    final_rgb *= vignette;

    COLOR = vec4(final_rgb, orig_color.a);
}
