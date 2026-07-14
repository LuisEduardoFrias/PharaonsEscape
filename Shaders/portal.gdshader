shader_type canvas_item;

// Controla la activación del efecto (0.0 = apagado, 1.0 = completamente activo)
uniform float effect_strength : hint_range(0.0, 1.0) = 0.03;

// Textura de ruido (puedes usar un FastNoiseLite en el inspector)
uniform sampler2D noise_texture : repeat_enable;
uniform vec2 speed = vec2(0.05, 0.05);
uniform float distortion_wave = 0.03;

void fragment() {
    // Desplazar el ruido con el tiempo para crear el movimiento de agua
    vec2 moving_uv = UV + TIME * speed;
    vec2 noise = texture(noise_texture, moving_uv).rg;
    
    // Calcular la distorsión basada en el ruido y la fuerza del efecto
    vec2 distortion = (noise - 0.5) * distortion_wave * effect_strength;
    
    // Aplicar la distorsión al sprite original
    vec4 texture_color = texture(TEXTURE, UV + distortion);
    
    // Opcional: Tinte azulado/portal cuando el efecto está activo
    vec4 portal_color = vec4(0.3, 0.5, 0.9, 1.0); 
    COLOR = mix(texture_color, texture_color * portal_color, effect_strength * 0.3);
}
