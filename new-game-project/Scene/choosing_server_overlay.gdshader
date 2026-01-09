/*
	CRT shader soft — vertical stripe reduced 95%
	Focus: readable text, minimal aperture grille
*/
shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;

uniform float crt_curve : hint_range(0.0, 1.0) = 0.006;
uniform float crt_scan_line_color : hint_range(0.0, 1.0) = 0.10;

// stripe giảm cực mạnh
uniform float aperture_strength : hint_range(0.0, 1.0) = 0.05;

// blur tắt
uniform float rf_switch_esque_blur : hint_range(0.0, 1.0) = 0.0;

float random(vec2 pos){
	return fract(sin(dot(pos, vec2(12.9898,78.233))) * 43758.5453);
}

void fragment(){
	vec2 crt_curve_shift = (vec2(1.0) - sin(UV.yx * PI)) * crt_curve;
	vec2 crt_curve_scale = 1.0 + crt_curve_shift * 2.0;
	vec2 fixed_uv = SCREEN_UV * crt_curve_scale - crt_curve_shift;

	vec3 base_col = texture(screen_texture, fixed_uv).rgb;

	// ---------- stripe công thức gốc (3 px cycle) ----------
	float p = mod(
		((SCREEN_UV.x * crt_curve_scale.x) - crt_curve_shift.x) / SCREEN_PIXEL_SIZE.x,
		3.0
	);

	// gốc: R G B mapping
	float r = clamp(1.0 - p, 0.0, 1.0) + clamp(p - 2.0, 0.0, 1.0);
	float g = clamp(1.0 - abs(1.0 - p), 0.0, 1.0);
	float b = 1.0 - r - g;

	// ---------- GIẢM STRIPE 95% ----------
	vec3 stripe = vec3(r, g, b);
	stripe = mix(vec3(1.0), stripe, aperture_strength);
	// aperture_strength = 0.05 → stripe chỉ 5%

	vec3 final_color = base_col * stripe;

	// scanline
	float scan = float(int(fixed_uv.y / SCREEN_PIXEL_SIZE.y) % 2 == 0);
	final_color = mix(final_color, vec3(0.0), scan * crt_scan_line_color);

	COLOR = vec4(final_color, 1.0);
}
