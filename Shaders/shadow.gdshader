shader_type canvas_item;

uniform vec4 shadow_color : source_color = vec4(0.0, 0.0, 0.0, 0.6);
uniform vec2 dash_offset = vec2(-0.1, 0.0); // Desplazamiento de la estela

void fragment() {
    // 1. Dibuja el píxel original de la textura recortada por el Atlas
    vec4 main_tex = texture(TEXTURE, UV);
    
    // 2. Calcula el desplazamiento dentro del RECTANGULO DE LA REGION del Atlas
    vec2 offset_uv = UV - (dash_offset * REGION_RECT.zw / vec2(textureSize(TEXTURE, 0)));
    vec4 shadow_tex = texture(TEXTURE, offset_uv);
    
    // 3. Aplica la sombra sobre el canal alfa de la silueta recortada
    vec4 final_shadow = vec4(shadow_color.rgb, shadow_tex.a * shadow_color.a);
    
    // 4. Mezcla la sombra detrás de la imagen principal
    COLOR = mix(final_shadow, main_tex, main_tex.a);
}
