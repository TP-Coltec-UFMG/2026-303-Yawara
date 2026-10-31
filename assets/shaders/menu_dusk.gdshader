shader_type canvas_item;
render_mode unshaded;
void fragment() {
    float bottom = smoothstep(0.36, 0.91, UV.y);
    float top = 1.0 - smoothstep(0.0, 0.23, UV.y);
    COLOR = vec4(0.012, 0.052, 0.052, clamp(bottom * 0.78 + top * 0.22, 0.0, 0.82));
}
