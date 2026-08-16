shader_type canvas_item;

uniform float velocidad : hint_range(0.1, 10.0) = 2.0;
uniform float brillo_min : hint_range(0.0, 1.0) = 0.2;
uniform float brillo_max : hint_range(1.0, 5.0) = 2.5;

// Función de ruido simple para desincronizar el parpadeo
float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec4 color_original = texture(TEXTURE, UV);
    
    // Ignorar píxeles transparentes
    if (color_original.a > 0.0) {
        // Generar una fase única basada en la posición UV del píxel/estrella
        float offset = rand(floor(UV * 100.0)) * 6.28318;
        
        // Calcular la intensidad del brillo usando una onda senoidal
        float factor = (sin(TIME * velocidad + offset) + 1.0) * 0.5;
        float intensidad = mix(brillo_min, brillo_max, factor);
        
        // Aplicar el brillo manteniendo la transparencia original
        COLOR = vec4(color_original.rgb * intensidad, color_original.a);
    } else {
        COLOR = color_original;
    }
}
