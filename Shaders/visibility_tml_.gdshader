shader_type canvas_item;

// Posición global del jugador/habilidad y el radio actual del círculo
uniform vec2 player_global_position;
uniform float skill_radius = 0.0;

// Recibimos la matriz de transformación global para convertir coordenadas
varying vec2 global_position;

void vertex() {
    // Calculamos la posición global de cada píxel
    global_position = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
    // Leemos el color original del tile de roca
    vec4 tex_color = texture(TEXTURE, UV);
    
    // Calculamos la distancia entre este píxel global y el centro de la habilidad
    float dist = distance(global_position, player_global_position);
    
    // Si el píxel está dentro del radio, lo hacemos invisible (alpha = 0)
    if (dist < skill_radius) {
        discard; // O también: tex_color.a = 0.0;
    }
    
    COLOR = tex_color;
}
