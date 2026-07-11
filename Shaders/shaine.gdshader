shader_type canvas_item;

uniform bool is_label = false;
uniform vec4 shine_color : source_color = vec4(1.0, 1.0, 1.0, 0.25);

uniform float shine_speed : hint_range(0.0, 10.0, 0.1) = 1.0;
uniform float shine_size : hint_range(0.01, 1.0, 0.01) = 0.2;
uniform float shine_softness : hint_range(0.0, 1.0, 0.01) = 0.5;
uniform float spacing : hint_range(0.1, 10.0, 0.1) = 1.5;
uniform float angle : hint_range(0.0, 360.0, 0.1) = 45.0;

void fragment() {
    // 1. Lógica de coordenadas para el brillo
    float a_rad = radians(angle);
    float cos_a = cos(a_rad);
    float sin_a = sin(a_rad);
    float rotated_uv = (UV.x * cos_a - UV.y * sin_a);

    float time = TIME * shine_speed;
    float cycle = mod(rotated_uv - time, spacing);

    float half_size = shine_size / 2.0;
    float edge0 = spacing / 2.0 - half_size;
    float edge1 = spacing / 2.0 + half_size;

    float intensity = smoothstep(edge0 - shine_softness, edge0, cycle) -
                      smoothstep(edge1, edge1 + shine_softness, cycle);

    float shine_alpha = intensity * shine_color.a;

    // 2. Lógica diferenciada por tipo de nodo
    if (is_label) {
        // Para Label: Respetamos el color y el alpha del texto original
        vec4 text_color = COLOR;
        text_color.a *= texture(TEXTURE, UV).a;

        vec3 final_rgb = mix(text_color.rgb, shine_color.rgb, shine_alpha);
        COLOR = vec4(final_rgb, text_color.a);
    } else {
        // Para ColorRect: El brillo se dibuja aunque el fondo sea transparente
        // Usamos el color base del ColorRect por si quieres que tenga un fondo
        vec4 base_rect_color = COLOR;

        // Mezclamos el fondo del rect con el brillo
        vec3 final_rgb = mix(base_rect_color.rgb, shine_color.rgb, shine_alpha);

        // El Alpha resultante es el alpha del fondo MÁS el alpha del brillo
        // Esto permite que si el fondo es 0, el brillo se siga viendo
        float final_alpha = max(base_rect_color.a, shine_alpha);

        COLOR = vec4(final_rgb, final_alpha);
    }
}
