/*
Shader de Niebla Atmosférica Sustractiva Multi-Luz (Godot 4.6)
Controla la fuerza de disipación de TODAS las luces desde el Inspector.
*/
shader_type canvas_item;

render_mode blend_sub, unshaded;

uniform vec4 fog_color : source_color = vec4(0.08, 0.07, 0.1, 0.3);
uniform float density : hint_range(0.0, 2.0) = 0.5;

uniform vec2 wind_direction = vec2(0.5, 0.1);
uniform float wind_speed = 40.0;
uniform float fog_scale_pixels = 90.0; 

// PARÁMETRO SOLICITADO: Controla qué tan fuerte las luces barren la niebla
// Valores altos (ej. 3.0, 5.0) harán que CUALQUIER antorcha limpie la niebla con mucha más fuerza y amplitud.
uniform float light_clear_strength : hint_range(1.0, 10.0) = 2.0;

varying vec2 world_pixel_coords;

void vertex() {
    world_pixel_coords = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
    vec2 wind_offset = wind_direction * (TIME * wind_speed);
    vec2 moving_pixels = world_pixel_coords + wind_offset;
    
    vec2 noise_uv = moving_pixels / fog_scale_pixels;
    
    vec2 i = floor(noise_uv);
    vec2 f = fract(noise_uv);
    
    float a = fract(sin(dot(i, vec2(56.0, 78.0))) * 43758.5453);
    float b = fract(sin(dot(i + vec2(1.0, 0.0), vec2(56.0, 78.0))) * 43758.5453);
    float c = fract(sin(dot(i + vec2(0.0, 1.0), vec2(56.0, 78.0))) * 43758.5453);
    float d = fract(sin(dot(i + vec2(1.0, 1.0), vec2(56.0, 78.0))) * 43758.5453);
    vec2 u = f * f * (3.0 - 2.0 * f);
    float n = mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
    
    vec2 moving_pixels_detail = (moving_pixels * 1.8 + (wind_offset * 0.5)) / fog_scale_pixels;
    vec2 i2 = floor(moving_pixels_detail);
    vec2 f2 = fract(moving_pixels_detail);
    float a2 = fract(sin(dot(i2, vec2(56.0, 78.0))) * 43758.5453);
    float b2 = fract(sin(dot(i2 + vec2(1.0, 0.0), vec2(56.0, 78.0))) * 43758.5453);
    float c2 = fract(sin(dot(i2 + vec2(0.0, 1.0), vec2(56.0, 78.0))) * 43758.5453);
    float d2 = fract(sin(dot(i2 + vec2(1.0, 1.0), vec2(56.0, 78.0))) * 43758.5453);
    vec2 u2 = f2 * f2 * (3.0 - 2.0 * f2);
    float n_detalle = mix(a2, b2, u2.x) + (c2 - a2) * u2.y * (1.0 - u2.x) + (d2 - b2) * u2.x * u2.y;
    
    float n_final = mix(n, n_detalle, 0.3);
    float opacidad_niebla = n_final * density * fog_color.a;
    
    // Multiplicamos la base del color por el parámetro de fuerza.
    // Al aumentar este valor, la matemática de blend_sub obliga a que el corte de la luz 
    // sea mucho más agresivo y amplio sobre los píxeles de la pantalla.
    vec3 color_procesado = (vec3(1.0) - fog_color.rgb) * light_clear_strength;
    
    COLOR = vec4(color_procesado, opacidad_niebla);
}
