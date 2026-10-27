shader_type canvas_item;

// captura el fondo que esta atras
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

// controles del espejismo :p
uniform float velocidad = 1.0;
uniform float fuerza = 0.005;
uniform float frecuencia = 40.0;

void fragment() {
    vec2 uv_movida = SCREEN_UV;
    
    // crea el efecto de onda de calor
    uv_movida.x += sin(uv_movida.y * frecuencia + TIME * velocidad) * fuerza;
    
    // distorsion de pixeles
    COLOR = texture(screen_texture, uv_movida);
}
