shader_type canvas_item;

uniform float speed = 2.0;
uniform float glow_width = 0.15; // độ dày vùng sáng chạy quanh
uniform vec4 glow_color : source_color = vec4(1.0, 0.6, 0.1, 1.0);

void fragment() {
    vec4 tex = texture(TEXTURE, UV);

    // chỉ vẽ trên vùng alpha > 0
    if (tex.a < 0.1) {
        discard;
    }

    float t = TIME * speed;

    // tính 4 chiều border
    float left   = UV.x;
    float right  = 1.0 - UV.x;
    float top    = UV.y;
    float bottom = 1.0 - UV.y;

    // lấy border gần nhất
    float edge = min(min(left, right), min(top, bottom));

    // hiệu ứng chạy quanh border
    float glow = smoothstep(glow_width, 0.0, abs(sin((t + left + top) * 6.283)));

    vec4 final_color = tex;
    final_color.rgb += glow_color.rgb * glow;

    COLOR = final_color;
}
