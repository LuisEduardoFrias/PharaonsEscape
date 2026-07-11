shader_type canvas_item;

// 0.0 = Invisible (derecha), 1.0 = Visible (izquierda)
uniform float progreso : hint_range(0.0, 1.0) = 0.0;
uniform vec4 color_texto : source_color = vec4(1.0);

void fragment() {
    // 1. Obtenemos el dibujo de la letra
    vec4 tex = texture(TEXTURE, UV);
    
    // 2. Usamos la posición de la pantalla para un barrido uniforme
    float x_pantalla = SCREEN_UV.x;
    
    // 3. El punto de corte que se mueve con el progreso
    float corte = 1.0 - progreso;
    
    // 4. Máscara: si la posición es mayor al corte, se muestra el color
    float mascara = step(corte, x_pantalla);
    
    // 5. Resultado final
    COLOR = color_texto;
    COLOR.a = tex.a * mascara;
}
