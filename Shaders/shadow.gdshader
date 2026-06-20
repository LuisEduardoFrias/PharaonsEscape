shader_type canvas_item;

uniform vec4 base_color : source_color = vec4(0.0, 0.0, 0.0, 0.6);
uniform sampler2D noise_texture : repeat_enable;
uniform vec2 speed = vec2(0.0, 0.05);

// NUEVO: Aquí pasaremos un degradado para suavizar los bordes
uniform sampler2D mask_texture; 

void fragment() {
    // 1. Leemos el valor alpha de nuestra máscara hecha a mano
    float mask = texture(mask_texture, UV).a;
    
    // 2. Leemos el ruido en movimiento
    vec2 shifted_uv = UV + TIME * speed;
    float noise = texture(noise_texture, shifted_uv).r;
    
    // 3. Multiplicamos todo: el borde suave (mask) * las nubes (noise) * la opacidad base
    float final_alpha = mask * noise * base_color.a;
    
    COLOR = vec4(base_color.rgb, final_alpha);
}
