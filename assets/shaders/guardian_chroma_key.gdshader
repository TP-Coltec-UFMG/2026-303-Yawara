shader_type canvas_item;

uniform vec4 key_color : source_color = vec4(0.63, 0.65, 0.69, 1.0);
uniform float tolerance : hint_range(0.01, 0.40) = 0.12;
uniform bool remove_checkerboard = false;

void fragment() {
    vec4 pixel = texture(TEXTURE, UV);
    float key_distance = distance(pixel.rgb, key_color.rgb);
    float alpha_mask = smoothstep(tolerance * 0.55, tolerance, key_distance);

    if (remove_checkerboard) {
        float maximum = max(pixel.r, max(pixel.g, pixel.b));
        float minimum = min(pixel.r, min(pixel.g, pixel.b));
        float saturation = maximum - minimum;
        float brightness = (pixel.r + pixel.g + pixel.b) / 3.0;
        float neutral = 1.0 - smoothstep(0.035, 0.105, saturation);
        float bright_square = smoothstep(0.53, 0.70, brightness);
        alpha_mask *= 1.0 - neutral * bright_square;
    }

    pixel.a *= alpha_mask;
    COLOR = pixel;
}
