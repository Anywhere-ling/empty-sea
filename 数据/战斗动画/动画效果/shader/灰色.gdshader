shader_type canvas_item;

uniform float gray_factor : hint_range(0.0, 1.0) = 0.0; // 0 = 全灰，1 = 原色
uniform float flash : hint_range(0.0, 1.0) = 0.0;      // 0 = 无闪光，1 = 全白
uniform float flash_power : hint_range(0.1, 8.0) = 2.0; // 控制闪光曲线 (pow)

void fragment() {
    // 原色，包含 COLOR (self_modulate)
    vec4 tex_color = texture(TEXTURE, UV) * COLOR;

    // 灰度
    float gray = dot(tex_color.rgb, vec3(0.299, 0.587, 0.114));
    vec3 mixed = mix(vec3(gray), tex_color.rgb, gray_factor);

    // 用 flash 做向白色的混合；用 pow() 调整曲线感受
    float f = clamp(pow(flash, flash_power), 0.0, 1.0);
    vec3 final_rgb = mix(mixed, vec3(1.0), f);

    COLOR = vec4(final_rgb, tex_color.a);
}
