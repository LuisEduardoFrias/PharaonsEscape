shader_type canvas_item;

// Controla la transición: 0.0 = totalmente visible, 1.0 = totalmente invisible
uniform float progress : hint_range(0.0, 1.0) = 0.0;

// Textura de ruido (NoiseTexture2D) para dar la forma de disolución
uniform sampler2D noise_texture : repeat_enable;

// Grosor y color del borde "mágico" o resplandor
uniform float burn_size : hint_range(0.0, 0.25) = 0.05;
uniform vec4 burn_color : source_color = vec4(1.0, 0.6, 0.1, 1.0); // Naranja/Dorado mágico
void fragment() {
    // Tomamos el color original del nodo procesado por Godot (incluye self_modulate)
    vec4 main_color = COLOR;
    
    // Obtenemos el valor del ruido
    float noise_val = texture(noise_texture, UV).r;
    
    float adjusted_progress = progress * (1.0 + burn_size);
    
    if (noise_val < adjusted_progress - burn_size) {
        discard;
    } else if (noise_val < adjusted_progress) {
        COLOR = burn_color;
        COLOR.a *= main_color.a;
    } else {
        COLOR = main_color;
    }
}
