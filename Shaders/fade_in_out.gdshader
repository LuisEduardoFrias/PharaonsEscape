shader_type canvas_item;

// Posición en píxeles del jugador (desde el script)
uniform vec2 player_uv; 
// 0.0 = Negro absoluto, 1.0 = Pantalla limpia
uniform float fade_progress : hint_range(0.0, 1.0) = 1.0;

// --- NUEVOS PARÁMETROS PARA CONTROLAR EN EL INSPECTOR ---
// Controla qué tan fino es el ruido. Valores más altos (ej. 0.2 a 0.5) lo hacen más fino.
uniform float noise_scale : hint_range(0.01, 1.0) = 0.15;
// Fuerza del mordisco del ruido (qué tanto deforma el círculo)
uniform float noise_strength = 120.0;
// Controla el degradado de opacidad en el borde. Valores altos (ej. 200.0) dan un difuminado suave y opaco.
uniform float smoothness = 250.0; 

// Función matemática para aleatoriedad
float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

// Ruido base suave
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i + vec2(0.0,0.0)), hash(i + vec2(1.0,0.0)), u.x),
               mix(hash(i + vec2(0.0,1.0)), hash(i + vec2(1.0,1.0)), u.x), u.y);
}

// Ruido Fractal (FBM) para lograr detalles mucho más finos y naturales
float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    // Procesamos 3 capas de ruido superpuestas para dar finura
    for (int i = 0; i < 3; i++) {
        value += amplitude * noise(p * frequency);
        frequency *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

void fragment() {
    vec2 screen_size = 1.0 / SCREEN_PIXEL_SIZE;
    vec2 current_pixel = UV * screen_size;
    
    // 1. Generamos el ruido fino usando el parámetro de escala
    float n = fbm(current_pixel * noise_scale); 
    
    // 2. Medir la distancia directa al jugador
    float dist = distance(current_pixel, player_uv);
    
    // 3. Aplicamos el ruido fino para deformar sutilmente el borde
    dist += n * noise_strength;
    
    // 4. Calculamos el radio máximo de apertura
    float max_radius = length(screen_size) * fade_progress;
    
    // 5. Máscara con degradado suave (Opacidad progresiva desde los bordes)
    // Al usar un 'smoothness' alto, se crea esa transición suave que buscas
    float mask = smoothstep(max_radius, max_radius - smoothness, dist);
    
    // Pintamos de negro controlando el canal Alpha (transparencia) con la máscara
    COLOR = vec4(vec3(0.0), 1.0 - mask);
}
